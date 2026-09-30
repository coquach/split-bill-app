//
//  ModelsTests.swift
//  DomainsTests
//

import Domains
import Foundation
import Testing

@Suite("SplitBillListItem")
struct SplitBillListItemTests {
    private func makeItem(requiredSlots: Int, paidSlots: Int) -> SplitBillListItem {
        SplitBillListItem(
            id: UUID(),
            requesterId: UUID(),
            sourceTransferId: UUID(),
            title: "Dinner",
            note: nil,
            totalAmount: 300_000,
            currency: "VND",
            participantCount: requiredSlots + 1,
            perPersonAmount: 100_000,
            requesterAmount: 100_000,
            requiredSlots: requiredSlots,
            paidSlots: paidSlots,
            status: .active,
            expiresAt: nil,
            closedAt: nil,
            createdAt: Date(timeIntervalSince1970: 0),
            isRequester: true,
            hasRepaid: false
        )
    }

    @Test(arguments: [(3, 0, 3), (3, 1, 2), (3, 3, 0)])
    func remainingSlotsIsRequiredMinusPaid(required: Int, paid: Int, remaining: Int) {
        #expect(makeItem(requiredSlots: required, paidSlots: paid).remainingSlots == remaining)
    }

    @Test
    func remainingSlotsClampsAtZeroWhenOverpaid() {
        // Defensive: the server should never report more paid slots than
        // required, but the model must not go negative if it does.
        #expect(makeItem(requiredSlots: 2, paidSlots: 5).remainingSlots == 0)
    }
}

@Suite("TransferReceipt")
struct TransferReceiptTests {
    private let transaction = makeTransaction(
        description: "Server description",
        amount: 500_000,
        fee: 2000,
        status: .success
    )

    @Test
    func prefersTheServerDescriptionOverTheDraft() {
        let receipt = TransferReceipt(
            transaction: transaction,
            draft: makeDraft(description: "Draft description")
        )
        #expect(receipt.description == "Server description")
    }

    @Test
    func fallsBackToTheDraftWhenTheServerNullsTheDescription() {
        let receipt = TransferReceipt(
            transaction: makeTransaction(description: nil),
            draft: makeDraft(description: "Draft description")
        )
        #expect(receipt.description == "Draft description")
    }

    @Test
    func carriesReceiverFieldsFromTheDraftAndMoneyFromTheTransaction() {
        let draft = makeDraft(
            receiverAccountNumber: "9876543210",
            receiverHolderName: "Binh Tran"
        )
        let receipt = TransferReceipt(transaction: transaction, draft: draft)

        #expect(receipt.receiverAccountNumber == "9876543210")
        #expect(receipt.receiverHolderName == "Binh Tran")
        #expect(receipt.amount == Amount(500_000))
        #expect(receipt.fee == Amount(2000))
        #expect(receipt.status == .success)
        #expect(receipt.id == transaction.id)
        #expect(receipt.transactionRef == "TX-001")
    }
}
