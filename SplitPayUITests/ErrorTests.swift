//
//  ErrorTests.swift
//  SplitPayUITests
//

import SystemDesign
import XCTest

/// Failure injection through UITEST_SCENARIO: repository throws, OTP reject,
/// QR decode failure — plus the empty dataset states.
final class ErrorTests: UITestCase {
    func testHistoryFetchFailureShowsRetry() {
        launch(scenario: "history-fails")
        tapTab(identifier: UITestID.tabHistory, label: "History")

        // The failed state renders an error banner and a retry button.
        XCTAssertTrue(app.buttons["Try Again"].waitForExistence(timeout: 5))

        // Retrying hits the same failing mock — the error stays up.
        app.buttons["Try Again"].tap()
        XCTAssertTrue(app.buttons["Try Again"].waitForExistence(timeout: 5))
    }

    func testHistoryEmptyState() {
        launch(data: "empty")
        tapTab(identifier: UITestID.tabHistory, label: "History")

        XCTAssertTrue(app.staticTexts["No transactions yet"].waitForExistence(timeout: 5))
    }

    func testTransferOtpFailureShowsErrorModal() {
        launch(scenario: "otp-fails")
        wait(UITestID.homeBalance)

        tap(UITestID.homeTransferAction)
        type(UITestID.transferReceiverField, UITestMagicValues.recipientAccountNumber)
        tap("transfer.chip.500K")
        tap(UITestID.transferContinue)
        wait(UITestID.transferConfirm)
        tap(UITestID.transferConfirm)

        wait(UITestID.transferOtpInput)
        type(UITestID.transferOtpInput, "123456")
        app.buttons["Verify"].tap()

        // AppModal is an overlay, not a system alert — query by identifier.
        waitErrorModal()
        tap(UITestID.errorModalRetry)

        // Retry clears the modal and stays on the PIN screen.
        wait(UITestID.transferOtpInput)
    }

    /// PIN_LOCKED — the server locks the PIN after 5 failed attempts; the
    /// modal must show the 10-minute lockout message.
    func testTransferPinLockedShowsLockoutMessage() {
        launch(scenario: "pin-locked")
        wait(UITestID.homeBalance)

        tap(UITestID.homeTransferAction)
        type(UITestID.transferReceiverField, UITestMagicValues.recipientAccountNumber)
        tap("transfer.chip.500K")
        tap(UITestID.transferContinue)
        wait(UITestID.transferConfirm)
        tap(UITestID.transferConfirm)

        wait(UITestID.transferOtpInput)
        type(UITestID.transferOtpInput, "123456")
        app.buttons["Verify"].tap()

        waitErrorModal()
        assertErrorModalMessage(contains: "locked for 10 minutes")

        tap(UITestID.errorModalRetry)
        wait(UITestID.transferOtpInput)
    }

    /// PIN_NOT_SET — the server rejects money movement until a PIN exists;
    /// the modal must point the user at the Profile screen.
    func testTransferPinNotSetShowsSetupMessage() {
        launch(scenario: "pin-not-set")
        wait(UITestID.homeBalance)

        tap(UITestID.homeTransferAction)
        type(UITestID.transferReceiverField, UITestMagicValues.recipientAccountNumber)
        tap("transfer.chip.500K")
        tap(UITestID.transferContinue)
        wait(UITestID.transferConfirm)
        tap(UITestID.transferConfirm)

        wait(UITestID.transferOtpInput)
        type(UITestID.transferOtpInput, "123456")
        app.buttons["Verify"].tap()

        waitErrorModal()
        assertErrorModalMessage(contains: "set up your transaction PIN in Profile")

        tap(UITestID.errorModalRetry)
        wait(UITestID.transferOtpInput)
    }

    /// The repay flow hits the same PIN lockout through the QR repayment RPC.
    func testRepayPinLockedShowsLockoutMessage() {
        launch(scenario: "pin-locked")

        tap(UITestID.scanQR)
        wait(UITestID.repayReviewConfirm)
        tap(UITestID.repayReviewConfirm)

        wait(UITestID.repayPinInput)
        type(UITestID.repayPinInput, "123456")
        app.buttons["Verify"].tap()

        waitErrorModal()
        assertErrorModalMessage(contains: "locked for 10 minutes")
    }

    func testQRDecodeFailureShowsErrorModal() {
        launch(scenario: "qr-decode-fails")

        // The scanner "reads" the failing payload ~0.3s after opening.
        tap(UITestID.scanQR)

        waitErrorModal()
        // The modal overlay covers the close button — dismiss it first, then
        // close the scanner and land back on Home.
        tap(UITestID.errorModalRetry)
        tap(UITestID.scanClose)
        wait(UITestID.homeBalance)
    }
}
