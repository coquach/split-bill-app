//
//  Fixtures.swift
//  DomainsTests
//

import Domains
import Foundation

func makeWallet(
    balance: Int64 = 1_000_000,
    walletNumber: String = "0123456789",
    walletHolderName: String = "An Nguyen",
    currency: String = "VND"
) -> Wallet {
    Wallet(
        id: UUID(),
        userId: UUID(),
        walletNumber: walletNumber,
        walletHolderName: walletHolderName,
        isDefault: true,
        status: .active,
        balance: balance,
        currency: currency,
        createdAt: Date(timeIntervalSince1970: 0),
        updatedAt: Date(timeIntervalSince1970: 0)
    )
}

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

func makeDraft(
    receiverWalletId: UUID = UUID(),
    receiverAccountNumber: String = "9876543210",
    receiverHolderName: String = "Binh Tran",
    amount: Amount = Amount(500_000),
    description: String = "Lunch"
) -> TransferDraft {
    TransferDraft(
        receiverWalletId: receiverWalletId,
        receiverAccountNumber: receiverAccountNumber,
        receiverHolderName: receiverHolderName,
        amount: amount,
        description: description
    )
}
