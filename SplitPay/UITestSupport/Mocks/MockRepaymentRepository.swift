//
//  MockRepaymentRepository.swift
//  SplitPay
//

#if DEBUG
    import Domains
    import Foundation

    final nonisolated class MockRepaymentRepository: IRepaymentRepository, @unchecked Sendable {
        private let store: MockAppStore

        private(set) var createRepaymentCalls = 0
        private(set) var lastRepaymentCommand: CreateQRRepaymentCommand?

        init(store: MockAppStore) {
            self.store = store
        }

        func createQRRepayment(_ command: CreateQRRepaymentCommand) async throws -> QRRepaymentReceipt {
            createRepaymentCalls += 1
            lastRepaymentCommand = command

            guard command.pin != UITestSeedData.failingPin else {
                throw DomainError.invalidPin
            }
            guard let splitBill = store.splitBills.first(where: { $0.id == UITestSeedData.UITestIDs.activeSplitBill })
            else {
                throw DomainError.notFound
            }

            store.debit(Int64(splitBill.perPersonAmount.amount))
            let now = Date()
            let receipt = QRRepaymentReceipt(
                id: UUID(),
                splitBillId: splitBill.id,
                transferTransactionId: UUID(),
                amount: splitBill.perPersonAmount,
                paymentMethod: .qrTransfer,
                status: .success,
                paidSlots: splitBill.paidSlots + 1,
                splitBillStatus: splitBill.status,
                paidAt: now
            )
            store.append(repayment:
                Repayment(
                    id: receipt.id,
                    splitBillId: splitBill.id,
                    payerUserId: store.user.id,
                    transferTransactionId: receipt.transferTransactionId,
                    paymentMethod: receipt.paymentMethod,
                    amount: receipt.amount,
                    currency: splitBill.currency,
                    payerDisplayName: "Bình Nguyễn",
                    note: command.note,
                    status: receipt.status,
                    idempotencyKey: command.idempotencyKey,
                    paidAt: receipt.paidAt,
                    createdAt: now
                )
            )
            return receipt
        }

        func getRepayments(splitBillId: UUID) async throws -> [Repayment] {
            store.repayments.filter { $0.splitBillId == splitBillId }
        }

        func getMyRepaymentRecords() async throws -> [RepaymentRecord] {
            store.repayments.map { RepaymentRecord(repayment: $0, splitBill: nil) }
        }
    }
#endif
