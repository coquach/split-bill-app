//
//  SmokeTests.swift
//  SplitPayUITests
//

import XCTest

/// Verifies the UI test target is wired correctly: the app builds, installs
/// and reaches its first real screen. Kept independent of the mock seam so it
/// runs before any app-side test support exists.
final class SmokeTests: XCTestCase {
    func testAppLaunches() {
        let app = XCUIApplication()
        app.launch()

        // Either the launch screen logo, the auth screen or the tab bar must
        // be reachable — anything proves the app process came up and rendered.
        let anythingRendered = app.tabBars.firstMatch.waitForExistence(timeout: 15)
            || app.buttons["Sign in"].waitForExistence(timeout: 2)
            || app.images.firstMatch.exists
        XCTAssertTrue(anythingRendered, "App did not render any known screen after launch")
    }
}
