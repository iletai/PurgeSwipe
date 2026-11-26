import CoreGraphics

/// Variance of the Laplacian: low values mean few sharp edges, i.e. a blurry photo.
enum Sharpness {
    /// 4-neighbour Laplacian variance over a row-major 8-bit grayscale buffer.
    static func laplacianVariance(gray: [UInt8], width: Int, height: Int) -> Double {
        guard width > 2, height > 2, gray.count >= width * height else { return 0 }
        var sum = 0.0
        var sumSquares = 0.0
        for y in 1 ..< (height - 1) {
            for x in 1 ..< (width - 1) {
                let center = Int(gray[y * width + x])
                let laplacian = Int(gray[(y - 1) * width + x]) + Int(gray[(y + 1) * width + x])
                    + Int(gray[y * width + x - 1]) + Int(gray[y * width + x + 1]) - 4 * center
                sum += Double(laplacian)
                sumSquares += Double(laplacian * laplacian)
            }
        }
        let count = Double((width - 2) * (height - 2))
        let mean = sum / count
        return sumSquares / count - mean * mean
    }

    /// Scores an image after downscaling its long side to `maxSide` pixels. nil when it cannot be rendered.
    static func score(of image: CGImage, maxSide: Int = 128) -> Double? {
        let scale = min(1, Double(maxSide) / Double(max(image.width, image.height)))
        let width = max(3, Int(Double(image.width) * scale))
        let height = max(3, Int(Double(image.height) * scale))
        var pixels = [UInt8](repeating: 0, count: width * height)
        let drawn = pixels.withUnsafeMutableBytes { buffer -> Bool in
            guard let context = CGContext(
                data: buffer.baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width,
                space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGImageAlphaInfo.none.rawValue
            ) else { return false }
            context.interpolationQuality = .medium
            context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
            return true
        }
        return drawn ? laplacianVariance(gray: pixels, width: width, height: height) : nil
    }
}

enum SimilarGrouping {
    /// Runs of neighbouring indices where each item is similar to the one before it. Only runs of two or more are returned.
    /// shortcut: neighbours only (burst / retake shots), not all-pairs; upgrade if users expect far-apart look-alikes.
    static func runs(count: Int, isSimilar: (Int, Int) -> Bool) -> [[Int]] {
        var result: [[Int]] = []
        var current: [Int] = []
        for index in 0 ..< count {
            if let last = current.last, isSimilar(last, index) {
                current.append(index)
            } else {
                if current.count > 1 { result.append(current) }
                current = [index]
            }
        }
        if current.count > 1 { result.append(current) }
        return result
    }
}
