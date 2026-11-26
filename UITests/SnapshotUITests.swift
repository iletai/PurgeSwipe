import XCTest

/// App Store screenshots (`bundle exec fastlane screenshots`); devices/languages in fastlane/Snapfile.
/// Not MainActor: default isolation would change the XCTestCase inits, which are nonisolated.
final nonisolated class SnapshotUITests: XCTestCase {
    @MainActor
    override func setUp() async throws {
        continueAfterFailure = false
    }

    @MainActor
    func testCaptureScreenshots() throws {
        let app = XCUIApplication()
        setupSnapshot(app)
        // Skip onboarding: store screenshots show the app, not the first-run tour.
        app.launchArguments += ["-hasCompletedOnboarding", "YES"]
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
        // Photos permission is pre-granted by the capture script; give the first analysis pass time.
        let deck = app.buttons["home.deck.similar"]
        XCTAssertTrue(deck.waitForExistence(timeout: 20))
        sleep(8)
        snapshot("01-home")

        deck.tap()
        XCTAssertTrue(app.buttons["deck.review"].waitForExistence(timeout: 15))
        sleep(2)
        snapshot("02-deck")

        for _ in 0..<3 { app.swipeLeft(velocity: .fast); sleep(1) }
        app.swipeRight(velocity: .fast)
        sleep(1)
        snapshot("03-swipe")

        app.buttons["deck.review"].tap()
        XCTAssertTrue(app.buttons["review.delete"].waitForExistence(timeout: 10))
        snapshot("04-review")
        app.navigationBars.buttons.firstMatch.tap()
        app.buttons["deck.back"].tap()

        app.buttons["home.settings"].tap()
        let plans = app.buttons["settings.viewPlans"]
        XCTAssertTrue(plans.waitForExistence(timeout: 10))
        plans.tap()
        // Products load asynchronously from the StoreKit config; wait for the price list.
        sleep(12)
        snapshot("05-paywall")
    }
}
