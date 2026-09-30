//
//  MockAppStore.swift
//  SplitPay
//
//  Shared mutable state for the in-memory mock repositories. UI flows touch
//  it from the main actor only, so the unchecked Sendable conformance is
//  acceptable for test support code.
//

#if DEBUG
    import Domains
    import Foundation

    final nonisolated class MockAppStore: @unchecked Sendable {
        let user: User
        let profile: Profile
        let pinIsSet: Bool

        private(set) var wallet: Wallet
        private(set) var transfers: [TransferHistory]
        private(set) var splitBills: [SplitBill]
        private(set) var repayments: [Repayment]

        init(seed: UITestSeedData) {
            user = seed.user
            profile = seed.profile
            pinIsSet = seed.pinIsSet
            wallet = seed.wallet
            transfers = seed.transfers
            splitBills = seed.splitBills
            repayments = seed.repayments
        }

        func debit(_ amount: Int64) {
            wallet = Wallet(
                id: wallet.id,
                userId: wallet.userId,
                walletNumber: wallet.walletNumber,
                walletHolderName: wallet.walletHolderName,
                isDefault: wallet.isDefault,
                status: wallet.status,
                balance: wallet.balance - amount,
                currency: wallet.currency,
                createdAt: wallet.createdAt,
                updatedAt: wallet.updatedAt
            )
        }

        func append(transfer: TransferTransaction, command _: CreateTransferCommand, recipient: WalletRecipient) {
            transfers.insert(
                TransferHistory(
                    id: transfer.id,
                    transactionRef: transfer.transactionRef,
                    direction: .sent,
                    senderUserId: user.id,
                    senderWalletId: wallet.id,
                    recipientUserId: UUID(),
                    recipientWalletId: recipient.walletId,
                    amount: transfer.amount,
                    fee: transfer.fee,
                    description: transfer.description,
                    status: transfer.status,
                    currency: wallet.currency,
                    counterpartyWalletNumber: recipient.walletNumber,
                    counterpartyName: recipient.holderName,
                    completedAt: transfer.completedAt,
                    createdAt: transfer.createdAt,
                    isRepayment: false,
                    repaymentId: nil,
                    totalCount: Int64(transfers.count + 1)
                ),
                at: 0
            )
        }

        func append(repayment: Repayment) {
            repayments.append(repayment)
        }

        func updateSplitBill(_ splitBill: SplitBill) {
            guard let index = splitBills.firstIndex(where: { $0.id == splitBill.id }) else {
                splitBills.insert(splitBill, at: 0)
                return
            }
            splitBills[index] = splitBill
        }
    }
#endif
