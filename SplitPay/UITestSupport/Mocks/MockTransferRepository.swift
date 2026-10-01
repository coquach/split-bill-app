//
//  MockTransferRepository.swift
//  SplitPay
//

#if DEBUG
    import Domains
    import Foundation

    final nonisolated class MockTransferRepository: ITransferRepository, @unchecked Sendable {
        private let store: MockAppStore

        private(set) var createTransferCalls = 0
        private(set) var lastCreateCommand: CreateTransferCommand?

        init(store: MockAppStore) {
            self.store = store
        }

        func createTransfer(_ command: CreateTransferCommand) async throws -> TransferTransaction {
            createTransferCalls += 1
            lastCreateCommand = command

            if UITestConfig.scenario == .otpFails {
                throw DomainError.invalidPin
            }
            if UITestConfig.scenario == .pinLocked {
                throw DomainError.pinLocked
            }
            if UITestConfig.scenario == .pinNotSet {
                throw DomainError.pinNotSet
            }
            guard command.amount <= store.wallet.balance else {
                throw DomainError.insufficientBalance
            }

            store.debit(command.amount)
            let transaction = TransferTransaction(
                id: UUID(),
                transactionRef: "TRX-\(1000 + createTransferCalls)",
                status: .success,
                amount: command.amount,
                fee: 0,
                description: command.description,
                completedAt: Date(),
                createdAt: Date()
            )
            store.append(
                transfer: transaction,
                command: command,
                recipient: WalletRecipient(
                    walletId: command.recipientWalletId,
                    walletNumber: UITestSeedData.recipientAccountNumber,
                    holderName: UITestSeedData.recipientHolderName
                )
            )
            return transaction
        }

        func getTransfers(
            page _: Int,
            pageSize _: Int,
            filter: TransactionTypeFilter
        ) async throws -> [TransferHistory] {
            if UITestConfig.scenario == .historyFails {
                throw DomainError.unknown(code: "UITEST", message: "History fetch failed")
            }

            let all = store.transfers
            switch filter {
            case .all:
                return all
            case .transfer:
                return all.filter { !$0.isRepayment }
            case .repayment:
                return all.filter(\.isRepayment)
            }
        }

        func getTransfer(id: UUID) async throws -> TransferDetail {
            guard let transfer = store.transfers.first(where: { $0.id == id }) else {
                throw DomainError.notFound
            }
            // Detail screen shows "Split Bill" only for a successful, SENT,
            // non-repayment transfer that has no split bill attached yet.
            let canCreateSplitBill = transfer.direction == .sent
                && !transfer.isRepayment
                && transfer.status == .success
            return TransferDetail(
                id: transfer.id,
                transactionRef: transfer.transactionRef,
                senderUserId: transfer.senderUserId,
                recipientUserId: transfer.recipientUserId,
                amount: transfer.amount,
                fee: transfer.fee,
                description: transfer.description,
                status: transfer.status,
                completedAt: transfer.completedAt,
                createdAt: transfer.createdAt,
                currency: transfer.currency,
                splitBillId: nil,
                canCreateSplitBill: canCreateSplitBill,
                isSplitBillRepayment: transfer.isRepayment
            )
        }
    }
#endif
