import AppTrackingTransparency
import GoogleMobileAds

/// AdMob bootstrap. Ask ATT first so the SDK starts with the user's choice.
/// Also needed outside code: app-ads.txt on the apps-site, ATT + data use in PrivacyInfo.xcprivacy and ASC privacy labels.
enum Ads {
    @MainActor
    static func start() async {
        _ = await ATTrackingManager.requestTrackingAuthorization()
        _ = await MobileAds.shared.start()
    }
}
