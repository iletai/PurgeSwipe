import Photos
import UIKit
import Vision

/// Finds the four decks on a background actor. Everything stays on device and iCloud-only originals are skipped.
/// shortcut: decks are rebuilt each launch (no SwiftData cache) and only the newest `maxImages` photos are compared;
/// upgrade to the cached 60-second-slice scan from the spec when libraries above ~3k photos feel slow.
actor AnalysisService {
    enum Event: Sendable {
        case progress(DeckKind, Double)
        case deck(DeckKind, [CleanupAsset])
    }

    typealias Sink = @MainActor @Sendable (Event) -> Void

    /// Laplacian variance below this counts as blurry. Tunable, calibrated on synthetic images only.
    static let blurThreshold = 100.0
    /// Vision feature-print distance below this counts as similar. Tunable.
    static let similarDistance: Float = 0.3
    static let similarWindow: TimeInterval = 30 * 24 * 3600
    static let maxImages = 1000
    static let maxVideos = 50
    static let blurryChunk = 4

    private struct Sample {
        let asset: CleanupAsset
        let date: Date
        let sharpness: Double
        let pixels: Int
        let print: VNFeaturePrintObservation?
    }

    func run(_ emit: Sink) async {
        await screenshots(emit)
        await videos(emit)
        await photos(emit)
    }

    private func fetch(_ type: PHAssetMediaType, predicate: String? = nil) -> [PHAsset] {
        let options = PHFetchOptions()
        options.predicate = predicate.map { NSPredicate(format: $0, PHAssetMediaSubtype.photoScreenshot.rawValue) }
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let result = PHAsset.fetchAssets(with: type, options: options)
        return result.objects(at: IndexSet(integersIn: 0 ..< result.count))
    }

    private func screenshots(_ emit: Sink) async {
        let assets = fetch(.image, predicate: "(mediaSubtypes & %d) != 0")
        var out: [CleanupAsset] = []
        for (index, asset) in assets.enumerated() {
            if Task.isCancelled { return }
            out.append(CleanupAsset(
                id: asset.localIdentifier,
                byteCount: PhotoLibrary.fileSize(of: asset),
                creationDate: asset.creationDate
            ))
            if index % 25 == 0 { await emit(.progress(.screenshots, Double(index) / Double(assets.count))) }
        }
        await emit(.deck(.screenshots, out))
    }

    private func videos(_ emit: Sink) async {
        let assets = fetch(.video)
        var all: [CleanupAsset] = []
        for (index, asset) in assets.enumerated() {
            if Task.isCancelled { return }
            all.append(CleanupAsset(
                id: asset.localIdentifier,
                byteCount: PhotoLibrary.fileSize(of: asset),
                isVideo: true,
                duration: asset.duration,
                creationDate: asset.creationDate
            ))
            if index % 25 == 0 { await emit(.progress(.videos, Double(index) / Double(assets.count))) }
        }
        let largest = all.sorted { $0.byteCount > $1.byteCount }.prefix(Self.maxVideos)
        await emit(.deck(.videos, Array(largest)))
    }

    /// One pass over the newest photos feeds both the Similar and the Blurry deck.
    private func photos(_ emit: Sink) async {
        // Filtered in Swift: the `== 0` bitmask predicate returned almost nothing on a real library.
        let assets = fetch(.image).filter { !$0.mediaSubtypes.contains(.photoScreenshot) }.prefix(Self.maxImages)
        var samples: [Sample] = []
        for (index, asset) in assets.enumerated() {
            if Task.isCancelled { return }
            if let sample = Self.sample(asset) { samples.append(sample) }
            if index % 10 == 0 {
                let fraction = Double(index) / Double(assets.count)
                await emit(.progress(.similar, fraction))
                await emit(.progress(.blurry, fraction))
            }
        }
        let blurry = Self.blurryDeck(samples)
        let similar = Self.similarDeck(samples)
        Log.photos.info("scan: \(assets.count) photos, \(samples.count) readable, \(blurry.count) blurry, \(similar.count) similar")
        await emit(.deck(.blurry, blurry))
        await emit(.deck(.similar, similar))
    }

    private static func blurryDeck(_ samples: [Sample]) -> [CleanupAsset] {
        samples.filter { $0.sharpness < blurThreshold }.enumerated().map { index, sample in
            var asset = sample.asset
            asset.group = index / blurryChunk
            return asset
        }
    }

    /// Per similar set the sharpest, largest shot is auto-kept; the rest become the swipe queue.
    private static func similarDeck(_ samples: [Sample]) -> [CleanupAsset] {
        let runs = SimilarGrouping.runs(count: samples.count) { first, second in
            let (a, b) = (samples[first], samples[second])
            guard abs(a.date.timeIntervalSince(b.date)) < similarWindow, let pa = a.print, let pb = b.print else { return false }
            var distance: Float = .greatestFiniteMagnitude
            return (try? pa.computeDistance(&distance, to: pb)) != nil && distance < similarDistance
        }
        return runs.enumerated().flatMap { group, run -> [CleanupAsset] in
            let best = run.max { (samples[$0].sharpness, samples[$0].pixels) < (samples[$1].sharpness, samples[$1].pixels) }
            return run.filter { $0 != best }.map { index in
                var asset = samples[index].asset
                asset.group = group
                return asset
            }
        }
    }

    private static func sample(_ asset: PHAsset) -> Sample? {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = false
        var image: UIImage?
        PHImageManager.default().requestImage(
            for: asset, targetSize: CGSize(width: 256, height: 256), contentMode: .aspectFit, options: options
        ) { result, _ in image = result }
        // No local thumbnail means an iCloud-only original: leave it out of every deck.
        guard let cgImage = image?.cgImage, let sharpness = Sharpness.score(of: cgImage) else { return nil }
        let request = VNGenerateImageFeaturePrintRequest()
        #if targetEnvironment(simulator)
            // The simulator has no neural engine ("Failed to create espresso context"); CPU-only works but returns degenerate
            // prints there (every distance 0), so judge similar-shot quality on a device.
            request.usesCPUOnly = true
        #endif
        try? VNImageRequestHandler(cgImage: cgImage).perform([request])
        return Sample(
            asset: CleanupAsset(
                id: asset.localIdentifier,
                byteCount: PhotoLibrary.fileSize(of: asset),
                creationDate: asset.creationDate
            ),
            date: asset.creationDate ?? .distantPast,
            sharpness: sharpness,
            pixels: asset.pixelWidth * asset.pixelHeight,
            print: request.results?.first
        )
    }
}
