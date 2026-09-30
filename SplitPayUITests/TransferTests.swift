//
//  TransferTests.swift
//  SplitPayUITests
//

import SystemDesign
import XCTest

/// Transaction history browsing and the full send-money flow:
/// input → lookup → confirm → PIN → success.
final class TransferTests: UITestCase {
    override func setUp() {
        super.setUp()
        launch()
        wait(UITestID.homeBalance)
    }

    // MARK: - History

    func testHistoryRendersSeededRows() {
        tapTab(identifier: UITestID.tabHistory, label: "History")

        wait("\(UITestID.historyRowPrefix).0")
        wait("\(UITestID.historyRowPrefix).1")
        wait("\(UITestID.historyRowPrefix).2")
        XCTAssertTrue(app.staticTexts["Trần Mai"].exists)
    }

    func testHistoryTransferFilter() {
        tapTab(identifier: UITestID.tabHistory, label: "History")
        wait("\(UITestID.historyRowPrefix).0")

        app.buttons["Transfer"].tap()

        // Two plain transfers remain; the received repayment drops out.
        wait("\(UITestID.historyRowPrefix).1")
        XCTAssertFalse(element("\(UITestID.historyRowPrefix).2").exists)
    }

    func testHistoryRepaymentFilter() {
        tapTab(identifier: UITestID.tabHistory, label: "History")
        wait("\(UITestID.historyRowPrefix).0")

        app.buttons["Repayment"].tap()

        wait("\(UITestID.historyRowPrefix).0")
        XCTAssertFalse(element("\(UITestID.historyRowPrefix).1").exists)
    }

    func testHistoryRowOpensTransactionDetail() {
        tapTab(identifier: UITestID.tabHistory, label: "History")
        tap("\(UITestID.historyRowPrefix).0")

        // The seeded first row is the sent "Team lunch" transfer, so the
        // detail screen offers the Split Bill action.
        wait(UITestID.detailSplitBill)
        XCTAssertTrue(app.staticTexts["Completed"].exists)
    }

    func testTransactionDetailSplitBillOpensSetup() {
        tapTab(identifier: UITestID.tabHistory, label: "History")
        tap("\(UITestID.historyRowPrefix).0")
        tap(UITestID.detailSplitBill)

        wait(UITestID.splitCreate)
        wait(UITestID.splitParticipantsMinus)
    }

    // MARK: - Transfer flow

    private func openTransferFlow() {
        tap(UITestID.homeTransferAction)
        wait(UITestID.transferReceiverField)
    }

    func testReceiverLookupResolvesHolderName() {
        openTransferFlow()

        type(UITestID.transferReceiverField, UITestMagicValues.recipientAccountNumber)

        // The mock resolves the account instantly and shows the holder.
        XCTAssertTrue(
            app.staticTexts[UITestMagicValues.recipientHolderName].waitForExistence(timeout: 5)
        )
    }

    func testTransferHappyPathReachesSuccess() {
        openTransferFlow()

        type(UITestID.transferReceiverField, UITestMagicValues.recipientAccountNumber)
        // The chip sets the amount deterministically — no keyboard needed.
        tap("transfer.chip.500K")
        tap(UITestID.transferContinue)

        wait(UITestID.transferConfirm)
        tap(UITestID.transferConfirm)

        wait(UITestID.transferOtpInput)
        type(UITestID.transferOtpInput, "123456")
        app.buttons["Verify"].tap()

        wait(UITestID.transferSuccessDone)
        tap(UITestID.transferSuccessDone)

        // Back to where the flow started.
        wait(UITestID.homeBalance)
    }

    func testAmountExceedingBalanceShowsWarning() {
        openTransferFlow()

        type(UITestID.transferReceiverField, UITestMagicValues.recipientAccountNumber)
        type(UITestID.transferAmountField, "99999999")

        let warning = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "exceeds your available balance")
        ).firstMatch
        XCTAssertTrue(warning.waitForExistence(timeout: 5))
        XCTAssertFalse(element(UITestID.transferContinue).isEnabled)
    }
}
