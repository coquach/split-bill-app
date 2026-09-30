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

        XCTAssertTrue(app.navigationBars["Change PIN"].waitForExistence(timeout: 5))
        app.buttons["Cancel"].tap()

        wait(UITestID.profilePinCard)
    }

    func testChangePinSucceeds() {
        tap(UITestID.profilePinCard)

        let fields = app.descendants(matching: .secureTextField).matching(identifier: UITestID.profilePinField)
        XCTAssertTrue(fields.firstMatch.waitForExistence(timeout: 5))

        fields.element(boundBy: 0).tap()
        fields.element(boundBy: 0).typeText("123456")
        fields.element(boundBy: 1).tap()
        fields.element(boundBy: 1).typeText("654321")
        fields.element(boundBy: 2).tap()
        fields.element(boundBy: 2).typeText("654321")

        tap(UITestID.profilePinSubmit)

        // Success dismisses the sheet back to the profile.
        wait(UITestID.profilePinCard)
    }

    func testLogoutReturnsToLogin() {
        tap(UITestID.profileLogout)

        wait(UITestID.loginEmail)
    }
}
