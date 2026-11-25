import Foundation

/// Values from Info.plist that Settings and About show. The build number comes from CI.
enum AppInfo {
    static var version: String { AppConfiguration.string("CFBundleShortVersionString") ?? "-" }
    static var build: String { AppConfiguration.string("CFBundleVersion") ?? "-" }
    static var versionDescription: String { "\(version) (\(build))" }
    static var copyright: String? { AppConfiguration.string("NSHumanReadableCopyright") }
}
