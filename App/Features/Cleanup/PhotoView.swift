import SwiftUI

/// Asset thumbnail with a neutral placeholder; failure shows a symbol, never a broken image.
struct PhotoView: View {
    let id: String
    var targetSize = CGSize(width: 300, height: 400)

    @State private var image: UIImage?
    @State private var failed = false

    var body: some View {
        Palette.fill
            .overlay {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else if failed {
                    Image(systemName: "photo")
                        .font(.title2)
                        .foregroundStyle(Palette.secondaryText)
                } else {
                    ProgressView()
                }
            }
            .clipped()
            .accessibilityHidden(true)
            .task(id: id) {
                image = nil
                failed = false
                image = await PhotoLibrary.image(id: id, targetSize: targetSize)
                failed = image == nil
            }
    }
}
