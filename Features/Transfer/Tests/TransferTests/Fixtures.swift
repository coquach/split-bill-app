//
//  Fixtures.swift
//  TransferTests
//

import Domains
import Foundation

func makeRecipient(
    walletId: UUID = UUID(),
    walletNumber: String = "9876543210",
    holderName: String = "Binh Tran"
) -> WalletRecipient {
    WalletRecipient(
        walletId: walletId,
        walletNumber: walletNumber,
        holderName: holderName
    )
}

func makeTransaction(
    description: String? = "Lunch",
    amount: Int64 = 500_000,
    fee: Int64 = 0,
    status: TransferStatus = .success,
    createdAt: Date = Date(timeIntervalSince1970: 1_700_000_000)
) -> TransferTransaction {
    TransferTransaction(
        id: UUID(),
        transactionRef: "TX-001",
        status: status,
        amount: amount,
        fee: fee,
        description: description,
        completedAt: createdAt,
        createdAt: createdAt
    )
}

func makeHistory(
    direction: TransferDirection = .sent,
    amount: Int64 = 200_000,
    counterpartyName: String? = "Binh Tran",
    counterpartyWalletNumber: String? = "9876543210",
    isRepayment: Bool = false,
    createdAt: Date = Date(timeIntervalSince1970: 1_700_000_000)
) -> TransferHistory {
    TransferHistory(
        id: UUID(),
        transactionRef: "TX-\(UUID().uuidString.prefix(4))",
        direction: direction,
        senderUserId: UUID(),
        senderWalletId: UUID(),
        recipientUserId: UUID(),
        recipientWalletId: UUID(),
        amount: amount,
        fee: 0,
        description: "Dinner",
        status: .success,
        currency: "VND",
        counterpartyWalletNumber: counterpartyWalletNumber,
        counterpartyName: counterpartyName,
        completedAt: createdAt,
        createdAt: createdAt,
        isRepayment: isRepayment,
        repaymentId: nil,
        totalCount: 1
    )
}

func makeDetail(
    amount: Int64 = 500_000,
    createdAt: Date = Date(timeIntervalSince1970: 1_700_000_000)
) -> TransferDetail {
    TransferDetail(
        id: UUID(),
        transactionRef: "TX-001",
        senderUserId: UUID(),
        recipientUserId: UUID(),
        amount: amount,
        fee: 0,
        description: "Lunch",
        status: .success,
        completedAt: createdAt,
        createdAt: createdAt,
        currency: "VND",
        splitBillId: nil,
        canCreateSplitBill: true,
        isSplitBillRepayment: false
    )
}
