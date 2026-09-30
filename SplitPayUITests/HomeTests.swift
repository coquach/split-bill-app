//
//  HomeTests.swift
//  SplitPayUITests
//

import SystemDesign
import XCTest

/// The signed-in landing screen against the seeded mock dataset.
final class HomeTests: UITestCase {
    override func setUp() {
        super.setUp()
        launch()
        wait(UITestID.homeBalance)
    }

    func testHomeShowsSeededContent() {
        // Profile header, balance card and quick actions all render.
        XCTAssertTrue(app.staticTexts["Bình Nguyễn"].exists)
        wait(UITestID.homeTransferAction)
        wait(UITestID.homeSplitAction)
        wait(UITestID.homeSeeAll)
    }

    func testHomeQuickActionTransferOpensTransferFlow() {
        tap(UITestID.homeTransferAction)

        wait(UITestID.transferReceiverField)
        wait(UITestID.transferAmountField)
        wait(UITestID.transferContinue)
    }

    func testHomeQuickActionSplitOpensSplitTab() {
        tap(UITestID.homeSplitAction)

        // The Split tab root is the split-bill history.
        wait("\(UITestID.splitHistoryRowPrefix).0")
        XCTAssertTrue(app.staticTexts["Team Lunch"].exists)
    }

    func testHomeSeeAllOpensTransactionHistory() {
        tap(UITestID.homeSeeAll)

        wait("\(UITestID.historyRowPrefix).0")
    }
}
