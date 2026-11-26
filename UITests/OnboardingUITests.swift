import XCTest

/// Baseline flow: onboarding is first-run only; Settings (pushed from Home) reaches Help and About.
final nonisolated class OnboardingUITests: XCTestCase {
    @MainActor
    override func setUp() async throws {
        continueAfterFailure = false
    }

    @MainActor
    func testSkipOnboardingReachesHome() throws {
        let app = XCUIApplication()
        // Forget any earlier photo answer so the system prompt appears again.
        app.resetAuthorizationStatus(for: .photos)
        // Clears the persisted flag so the app starts on the first-run tour.
        app.launchArguments += ["-resetOnboarding"]
        app.launch()

        XCTAssertTrue(app.buttons["onboarding.primary"].waitForExistence(timeout: 10))
        // Skip jumps to the permission page; only the system prompt leaves onboarding.
        app.buttons["onboarding.skip"].tap()
        app.buttons["onboarding.primary"].tap()
        // The photo prompt is a system alert; decline it (Home has a denied state).
        let denyPhotos = XCUIApplication(bundleIdentifier: "com.apple.springboard").buttons["Don\u{2019}t Allow"]
        if denyPhotos.waitForExistence(timeout: 5) { denyPhotos.tap() }
        XCTAssertTrue(app.buttons["home.settings"].waitForExistence(timeout: 10))
    }

    @MainActor
    func testSettingsOpensHelpAndAbout() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-hasCompletedOnboarding", "YES"]
        app.launch()

        app.buttons["home.settings"].tap()
        XCTAssertTrue(app.buttons["settings.help"].waitForExistence(timeout: 10))

        app.buttons["settings.help"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["help.root"].waitForExistence(timeout: 10))

        app.buttons["BackButton"].tap()
        // About sits below the fold now that the Pro section is on top of the form.
        let about = app.buttons["settings.about"]
        for _ in 0..<3 where !about.exists { app.swipeUp() }
        XCTAssertTrue(about.waitForExistence(timeout: 10))
        about.tap()
        XCTAssertTrue(app.descendants(matching: .any)["about.root"].waitForExistence(timeout: 10))
    }
}
