//
//  AuthTests.swift
//  SplitPayUITests
//

import SystemDesign
import XCTest

/// The unauthenticated entry: Login form validation, the sign-in round trip
/// and the push to Register — all against the mock auth repository.
final class AuthTests: UITestCase {
    override func setUp() {
        super.setUp()
        launch(authenticated: false)
    }

    func testLoginScreenRenders() {
        wait(UITestID.loginEmail)
        wait(UITestID.loginPassword)
        wait(UITestID.loginSubmit)
        wait(UITestID.loginSignUpLink)
    }

    func testLoginShowsErrorsLiveAndKeepsSubmitDisabledWhileInvalid() {
        // The fresh form opens clean — no "…is required." noise — and the
        // disabled submit keeps a tap on the empty form from doing anything.
        let submit = wait(UITestID.loginSubmit)
        XCTAssertFalse(submit.isEnabled)

        // Editing a field surfaces its error live, no submit tap needed.
        type(UITestID.loginEmail, "not-an-email")
        XCTAssertTrue(
            app.staticTexts["Please enter a valid email address."]
                .waitForExistence(timeout: 5)
        )

        // The untouched password field stays quiet.
        XCTAssertFalse(app.staticTexts["Password is required."].exists)
    }

    func testLoginInvalidCredentialsShowsAlert() {
        type(UITestID.loginEmail, UITestMagicValues.failingEmail)
        type(UITestID.loginPassword, "whatever123")
        tap(UITestID.loginSubmit)

        // Auth failures surface as a system alert, not an AppModal overlay.
        let alert = app.alerts["Unable to sign in"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))

        alert.buttons["OK"].tap()
        // Dismissing returns to the form, still signed out.
        wait(UITestID.loginEmail)
    }

    func testLoginSucceedsReachesHome() {
        type(UITestID.loginEmail, "uitest@splitpay.dev")
        type(UITestID.loginPassword, "password123")
        tap(UITestID.loginSubmit)

        wait(UITestID.tabHome)
        wait(UITestID.homeBalance)
    }

    func testNavigateToRegister() {
        tap(UITestID.loginSignUpLink)

        wait(UITestID.registerFullName)
        wait(UITestID.registerEmail)
        wait(UITestID.registerSubmit)
    }

    func testRegisterShowsErrorsLiveAndKeepsSubmitDisabledWhileInvalid() {
        tap(UITestID.loginSignUpLink)

        // The fresh form opens clean — no "…is required." noise — and the
        // disabled submit keeps a tap on the empty form from doing anything.
        let submit = wait(UITestID.registerSubmit)
        XCTAssertFalse(submit.isEnabled)

        // Editing a field surfaces its error live, no submit tap needed.
        type(UITestID.registerEmail, "not-an-email")
        XCTAssertTrue(
            app.staticTexts["Please enter a valid email address."]
                .waitForExistence(timeout: 5)
        )

        // The untouched fields stay quiet.
        XCTAssertFalse(app.staticTexts["Full name is required."].exists)

        // The submit is still disabled while the form is invalid.
        XCTAssertFalse(submit.isEnabled)
    }

    func testRegisterCreatesAccountAndReachesHome() {
        tap(UITestID.loginSignUpLink)

        type(UITestID.registerFullName, "Test User")
        type(UITestID.registerPhone, "0987654321")
        type(UITestID.registerEmail, "newuser@test.com")
        type(UITestID.registerPassword, "password123")
        type(UITestID.registerConfirmPassword, "password123")
        tap(UITestID.registerSubmit)

        // Sign-up success shows a "Check your email" confirmation alert.
        // The mock signs the new account in immediately, so the root may
        // already have swapped to the tabs — dismiss the alert only if it's
        // still up, then land on Home either way.
        let alert = app.alerts["Check your email"]
        if alert.waitForExistence(timeout: 5) {
            alert.buttons["OK"].tap()
        }
        wait(UITestID.tabHome)
        wait(UITestID.homeBalance)
    }
}
