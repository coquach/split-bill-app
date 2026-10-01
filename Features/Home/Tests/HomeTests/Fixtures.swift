//
//  Fixtures.swift
//  HomeTests
//

import Domains
import Foundation

func makeProfile(
    fullName: String? = "Binh Tran",
    email: String? = "binh@example.com",
    phoneNumber: String? = "0912345678",
    status: UserStatus = .active
) -> Profile {
    Profile(
        id: UUID(),
        fullName: fullName,
        phoneNumber: phoneNumber,
        email: email,
        biometricsEnabled: false,
        status: status,
        createdAt: Date(timeIntervalSince1970: 1_700_000_000),
        updatedAt: Date(timeIntervalSince1970: 1_700_000_000)
    )
}

func makeWallet(
    walletNumber: String = "9876543210",
    balance: Int64 = 1_000_000,
    currency: String = "VND"
) -> Wallet {
    Wallet(
        id: UUID(),
        userId: UUID(),
        walletNumber: walletNumber,
        walletHolderName: "Binh Tran",
        isDefault: true,
        status: .active,
        balance: balance,
        currency: currency,
        createdAt: Date(timeIntervalSince1970: 1_700_000_000),
        updatedAt: Date(timeIntervalSince1970: 1_700_000_000)
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
