import Testing
@testable import PurgeSwipe

struct SmokeTests {
    @Test func appLaunchesContentView() {
        _ = ContentView()
    }

    @Test func baselineScreensBuild() {
        _ = SettingsView()
        _ = HelpView()
        _ = AboutView()
    }

    @Test func legalAndSupportLinksAreConfigured() {
        #expect(AppConfiguration.privacyURL != nil)
        #expect(AppConfiguration.supportURL != nil)
        #expect(AppConfiguration.termsURL != nil)
        #expect(AppConfiguration.supportEmail != nil)
    }

    @Test func appearanceHasSystemLightAndDark() {
        #expect(AppAppearance.allCases == [.system, .light, .dark])
    }
}
