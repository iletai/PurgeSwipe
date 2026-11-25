import XCTest

/// Baseline flow: onboarding is first-run only; Settings reaches Help and About.
final nonisolated class OnboardingUITests: XCTestCase {
    @MainActor
    override func setUp() async throws {
        continueAfterFailure = false
    }

    @MainActor
    func testSkipOnboardingReachesHome() throws {
        let app = XCUIApplication()
        // Clears the persisted flag so the app starts on the first-run tour.
        app.launchArguments += ["-resetOnboarding"]
        app.launch()

        XCTAssertTrue(app.buttons["onboarding.primary"].waitForExistence(timeout: 10))
        app.buttons["onboarding.skip"].tap()
        XCTAssertTrue(app.buttons["home.settings"].waitForExistence(timeout: 10))
    }

    @MainActor
    func testSettingsOpensHelpAndAbout() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-hasCompletedOnboarding", "YES"]
        app.launch()

        app.buttons["home.settings"].tap()
        XCTAssertTrue(app.buttons["settings.done"].waitForExistence(timeout: 10))

        app.buttons["settings.help"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["help.root"].waitForExistence(timeout: 10))

        app.buttons["BackButton"].tap()
        XCTAssertTrue(app.buttons["settings.about"].waitForExistence(timeout: 10))
        app.buttons["settings.about"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["about.root"].waitForExistence(timeout: 10))
    }
}
