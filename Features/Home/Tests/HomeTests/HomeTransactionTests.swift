//
//  HomeTransactionTests.swift
//  HomeTests
//

import Domains
import Foundation
@testable import Home
import Testing

@Suite("HomeTransaction")
struct HomeTransactionTests {
    @Test
    func titlePrefersTheNameThenTheWalletNumberThenUnknown() {
        #expect(HomeTransaction(transaction: makeHistory(counterpartyName: "Binh Tran")).title == "Binh Tran")
        #expect(
            HomeTransaction(transaction: makeHistory(counterpartyName: nil, counterpartyWalletNumber: "9876543210"))
                .title == "9876543210"
        )
        #expect(
            HomeTransaction(transaction: makeHistory(counterpartyName: nil, counterpartyWalletNumber: nil))
                .title == "Unknown"
        )
    }

    @Test
    func subtitleNamesTheKindOfTransfer() {
        #expect(HomeTransaction(transaction: makeHistory(isRepayment: true)).subtitle == "Split payment")
        #expect(HomeTransaction(transaction: makeHistory(isRepayment: false)).subtitle == "Transfer")
    }

    @Test
    func incomingAmountsArePositiveAndOutgoingNegative() {
        let incoming = HomeTransaction(transaction: makeHistory(direction: .received, amount: 200_000))
        let outgoing = HomeTransaction(transaction: makeHistory(direction: .sent, amount: 200_000))

        #expect(incoming.amount == 200_000)
        #expect(incoming.isIncoming == true)
        #expect(outgoing.amount == -200_000)
        #expect(outgoing.isIncoming == false)
    }

    @Test
    func formattedAmountSignsAndLabelsTheValue() {
        let incoming = HomeTransaction(transaction: makeHistory(direction: .received, amount: 200_000))
        let outgoing = HomeTransaction(transaction: makeHistory(direction: .sent, amount: 200_000))

        // The inner formatter uses the host locale's separators, so pin the
        // structure rather than an exact string.
        for text in [incoming.formattedAmount, outgoing.formattedAmount] {
            #expect(text.hasSuffix(" VND"))
            #expect(text.contains("200"))
        }
        #expect(incoming.formattedAmount.hasPrefix("+"))
        #expect(outgoing.formattedAmount.hasPrefix("-"))
    }

    @Test
    func theTransactionCarriesItsIdentityAndDate() {
        let history = makeHistory(createdAt: Date(timeIntervalSince1970: 1_700_000_000))
        let transaction = HomeTransaction(transaction: history)

        #expect(transaction.id == history.id)
        #expect(transaction.createdAt == history.createdAt)
        #expect(!transaction.dateText.isEmpty)
    }
}
