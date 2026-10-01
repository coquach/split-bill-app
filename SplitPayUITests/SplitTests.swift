//
//  SplitTests.swift
//  SplitPayUITests
//

import SystemDesign
import XCTest

/// Split-bill history, setup and the repay-a-QR flow (camera replaced by the
/// mock scan payload injected through SplitBillCoordinator.Dependencies).
final class SplitTests: UITestCase {
    override func setUp() {
        super.setUp()
        launch()
        wait(UITestID.homeBalance)
    }

    // MARK: - History & details

    func testSplitHistoryShowsActiveBills() {
        tapTab(identifier: UITestID.tabSplit, label: "Split")

        wait("\(UITestID.splitHistoryRowPrefix).0")
        XCTAssertTrue(app.staticTexts["Team Lunch"].exists)
    }

    func testSplitHistorySettledFilter() {
        tapTab(identifier: UITestID.tabSplit, label: "Split")
        wait("\(UITestID.splitHistoryRowPrefix).0")

        app.buttons["Settled"].tap()

        // Movie Night is closed; Team Lunch (active) drops out.
        XCTAssertTrue(app.staticTexts["Movie Night"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["Team Lunch"].exists)
    }

    func testSplitDetailsShowsProgressAndActions() {
        tapTab(identifier: UITestID.tabSplit, label: "Split")
        tap("\(UITestID.splitHistoryRowPrefix).0")

        XCTAssertTrue(app.buttons["Get QR"].waitForExistence(timeout: 5))
        // 1 of 3 slots paid on the seeded Team Lunch bill.
        XCTAssertTrue(app.staticTexts["Paid 1 of 3"].waitForExistence(timeout: 5))
    }

    // MARK: - Setup

    /// Split setup is reached from a sent transfer's detail screen.
    private func openSplitSetup() {
        tapTab(identifier: UITestID.tabHistory, label: "History")
        tap("\(UITestID.historyRowPrefix).0")
        tap(UITestID.detailSplitBill)
        wait(UITestID.splitCreate)
    }

    func testSplitSetupStepperAdjustsParticipants() {
        openSplitSetup()

        let minus = element(UITestID.splitParticipantsMinus)
        let plus = element(UITestID.splitParticipantsPlus)
        XCTAssertTrue(minus.waitForExistence(timeout: 5))
        XCTAssertTrue(plus.exists)
        // Setup opens at the range's lower bound (2) — minus disabled until
        // the count is raised.
        XCTAssertFalse(minus.isEnabled)

        plus.tap()
        XCTAssertTrue(minus.waitForExistence(timeout: 5) && minus.isEnabled)
    }

    func testSplitCreateGeneratesQR() {
        openSplitSetup()
        tap(UITestID.splitCreate)

        wait(UITestID.splitQRSave)
    }

    // MARK: - Repay via scanned QR (mock payload)

    func testScanRepayHappyPath() {
        tap(UITestID.scanQR)

        // The injected payload decodes after ~0.3s and lands on review.
        wait(UITestID.repayReviewConfirm)
        tap(UITestID.repayReviewConfirm)

        wait(UITestID.repayPinInput)
        type(UITestID.repayPinInput, "123456")
        app.buttons["Verify"].tap()

        wait(UITestID.repaySuccessDone)
        tap(UITestID.repaySuccessDone)
    }

    func testRepayWrongPinShowsErrorModal() {
        tap(UITestID.scanQR)
        wait(UITestID.repayReviewConfirm)
        tap(UITestID.repayReviewConfirm)

        wait(UITestID.repayPinInput)
        type(UITestID.repayPinInput, UITestMagicValues.failingPin)
        app.buttons["Verify"].tap()

        waitErrorModal()
    }
}
