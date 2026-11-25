import AppUpdateKit
import Foundation

/// Force/optional update + maintenance from the microCMS `app-update` object (skill `iletai-libs`).
/// Fail-safe: a missing key or any fetch/decode error resolves to `.none`, so the CMS never blocks launch.
@MainActor
@Observable
final class AppUpdateService {
    static let shared = AppUpdateService()

    private(set) var action: AppUpdateAction = .none

    func check(policy: AppUpdateCheckPolicy = .oncePerSession) async {
        guard let domain = AppConfiguration.string("MICROCMS_SERVICE_DOMAIN"),
              let apiKey = AppConfiguration.string("MICROCMS_API_KEY"),
              let url = URL(string: "https://\(domain).microcms.io/api/v1/app-update")
        else {
            Log.app.notice("App update check skipped: microCMS not configured")
            return
        }
        action = await AppUpdateManager.shared.check(
            policy: policy,
            defaultStoreURL: AppConfiguration.appStoreURL,
            fetcher: AppUpdateFetcher.microCMS(endpoint: url, apiKey: apiKey)
        )
    }
}
