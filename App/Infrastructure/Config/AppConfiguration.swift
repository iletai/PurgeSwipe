import Foundation

/// Build-time values from Info.plist (fed by Config/*.xcconfig). Never hardcode them in Swift.
enum AppConfiguration {
    enum Environment: String {
        case dev, staging, prod
    }

    /// From `APP_ENV` (Config/{Dev,Staging,Prod}.xcconfig). Staging talks to the production backend.
    static let environment: Environment = {
        guard let raw = string("APP_ENV"), let env = Environment(rawValue: raw) else {
            preconditionFailure("APP_ENV missing or invalid in Info.plist")
        }
        return env
    }()

    static var bundleIdentifier: String { Bundle.main.bundleIdentifier ?? "" }

    /// nil until `APP_STORE_URL` is set in Config/Backend-Prod.xcconfig (always nil in Dev).
    static var appStoreURL: URL? { string("APP_STORE_URL").flatMap(URL.init(string:)) }

    /// In-app legal/support links, generated from the apps-site slug (project.yml info.properties).
    static var privacyURL: URL? { string("PRIVACY_POLICY_URL").flatMap(URL.init(string:)) }
    static var supportURL: URL? { string("SUPPORT_URL").flatMap(URL.init(string:)) }
    static var termsURL: URL? { string("TERMS_OF_USE_URL").flatMap(URL.init(string:)) }
    static var supportEmail: String? { string("SUPPORT_EMAIL") }
    static var bannerAdUnitID: String? { string("ADMOB_BANNER_UNIT_ID") }

    /// Custom Info.plist key; nil when missing or empty (unset xcconfig variables expand to "").
    static func string(_ key: String) -> String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String, !value.isEmpty else { return nil }
        return value
    }
}
