import GoogleMobileAds
import SwiftUI

/// 320x50 AdMob banner for Home. Collapses to nothing until an ad arrives, so a failed load leaves no empty box.
struct BannerAdView: View {
    @State private var loaded = false

    var body: some View {
        if let unitID = AppConfiguration.bannerAdUnitID {
            BannerRepresentable(unitID: unitID, loaded: $loaded)
                .frame(width: AdSizeBanner.size.width, height: loaded ? AdSizeBanner.size.height : 0)
                .frame(maxWidth: .infinity)
                .padding(.top, loaded ? 4 : 0)
                .accessibilityLabel("home.ad")
        }
    }
}

private struct BannerRepresentable: UIViewRepresentable {
    let unitID: String
    @Binding var loaded: Bool

    func makeCoordinator() -> Coordinator { Coordinator(loaded: $loaded) }

    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = unitID
        banner.delegate = context.coordinator
        banner.rootViewController = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow?.rootViewController }
            .first
        banner.load(Request())
        return banner
    }

    func updateUIView(_: BannerView, context _: Context) {}

    final class Coordinator: NSObject, BannerViewDelegate {
        private let loaded: Binding<Bool>

        init(loaded: Binding<Bool>) { self.loaded = loaded }

        func bannerViewDidReceiveAd(_: BannerView) { loaded.wrappedValue = true }

        func bannerView(_: BannerView, didFailToReceiveAdWithError error: Error) {
            loaded.wrappedValue = false
            Log.app.info("banner failed: \(error.localizedDescription, privacy: .public)")
        }
    }
}
