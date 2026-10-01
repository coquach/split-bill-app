//
//  ProfileTests.swift
//  SplitPayUITests
//

import SystemDesign
import XCTest

/// Profile screen fields, the PIN sheet and sign-out.
final class ProfileTests: UITestCase {
    override func setUp() {
        super.setUp()
        launch()
        tapTab(identifier: UITestID.tabProfile, label: "Profile")
    }

    func testProfileShowsSeededFields() {
        wait(UITestID.profilePinCard)
        XCTAssertTrue(app.staticTexts["Bình Nguyễn"].exists)
        XCTAssertTrue(app.staticTexts["uitest@splitpay.dev"].exists)
        XCTAssertTrue(app.staticTexts["0912345678"].exists)
        wait(UITestID.profileLogout)
    }

    func testChangePinSheetCancels() {
        // The seeded profile has a PIN, so the card opens the change sheet.
        tap(UITestID.profilePinCard)

        // The sheet hides the system navigation bar and draws its own
        // AppNavBar, so the title is a plain static text.
        XCTAssertTrue(app.staticTexts["Change PIN"].waitForExistence(timeout: 5))
        // The sheet's nav bar has a plain chevron back button, not "Cancel".
        tap(UITestID.profilePinBack)

        wait(UITestID.profilePinCard)
    }

    func testChangePinSucceeds() {
        tap(UITestID.profilePinCard)

        XCTAssertTrue(app.staticTexts["Change PIN"].waitForExistence(timeout: 5))

        // The PIN flow walks one step per screen — current, new, confirm —
        // each a single hidden code field behind the visible boxes.
        type(UITestID.profilePinField, "123456")
        app.buttons["Continue"].tap()

        type(UITestID.profilePinField, "654321")
        app.buttons["Continue"].tap()

        type(UITestID.profilePinField, "654321")
        app.buttons["Confirm"].tap()

        // Success shows an acknowledgement popup first; Done closes it and
        // the sheet back to the profile.
        wait(UITestID.profilePinSuccess)
        tap(UITestID.profilePinSuccessDone)

        wait(UITestID.profilePinCard)
    }

    func testLogoutReturnsToLogin() {
        tap(UITestID.profileLogout)

        // Log Out opens a confirmation modal first; Confirm actually signs out.
        app.buttons["Confirm"].tap()

        wait(UITestID.loginEmail)
    }
}
