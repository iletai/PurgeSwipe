import Photos
import PhotosUI
import UIKit

/// Thin PhotoKit wrapper: permission, thumbnails, deletion. Nothing leaves the device; iCloud-only originals are never downloaded.
enum PhotoLibrary {
    static var authorizationStatus: PHAuthorizationStatus {
        PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }

    static func requestAccess() async -> PHAuthorizationStatus {
        await PHPhotoLibrary.requestAuthorization(for: .readWrite)
    }

    /// Single-callback image request (`highQualityFormat`), local data only. nil when unavailable.
    static func image(id: String, targetSize: CGSize) async -> UIImage? {
        guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil).firstObject else { return nil }
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = false
        return await withCheckedContinuation { continuation in
            PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }

    /// Moves the assets to Recently Deleted. iOS shows its own confirmation; a cancel throws `.userCancelled`.
    static func delete(ids: [String]) async throws {
        try await PHPhotoLibrary.shared().performChanges {
            let assets = PHAsset.fetchAssets(withLocalIdentifiers: ids, options: nil)
            PHAssetChangeRequest.deleteAssets(assets)
        }
    }

    static func wasCancelled(_ error: Error) -> Bool {
        (error as? PHPhotosError)?.code == .userCancelled
    }

    /// Sum of every resource of every asset (Live Photos count both parts). `fileSize` is the key all cleaners use.
    nonisolated static func fileSize(of asset: PHAsset) -> Int64 {
        PHAssetResource.assetResources(for: asset).reduce(0) { total, resource in
            total + ((resource.value(forKey: "fileSize") as? NSNumber)?.int64Value ?? 0)
        }
    }

    /// `async` so it runs off the main actor.
    nonisolated static func totalBytes() async -> Int64 {
        let all = PHAsset.fetchAssets(with: nil)
        var total: Int64 = 0
        all.enumerateObjects { asset, _, stop in
            if Task.isCancelled { stop.pointee = true }
            total += fileSize(of: asset)
        }
        return total
    }

    @MainActor
    static func presentLimitedPicker() {
        let root = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow?.rootViewController }
            .first
        guard let root else { return }
        PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: root)
    }
}
