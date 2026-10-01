//
//  MockSplitQRRepository.swift
//  SplitPay
//

#if DEBUG
    import Domains
    import Foundation

    final nonisolated class MockSplitQRRepository: ISplitQRRepository, @unchecked Sendable {
        private let store: MockAppStore

        init(store: MockAppStore) {
            self.store = store
        }

        func getQR(splitBillId: UUID) async throws -> SplitQRCode {
            let now = Date()
            return SplitQRCode(
                id: UUID(),
                splitBillId: splitBillId,
                walletId: store.wallet.id,
                qrPayload: UITestSeedData.validQRPayload,
                isActive: true,
                expiresAt: Calendar.current.date(byAdding: .day, value: 7, to: now),
                createdAt: now,
                updatedAt: now
            )
        }

        func decodeQR(payload: String) async throws -> SplitQRReview {
            let shouldFail = UITestConfig.scenario == .qrDecodeFails
                || payload == UITestSeedData.failingQRPayload
            guard !shouldFail else {
                throw DomainError.notFound
            }
            guard payload == UITestSeedData.validQRPayload else {
                throw DomainError.notFound
            }
            guard let splitBill = store.splitBills.first(where: { $0.id == UITestSeedData.UITestIDs.activeSplitBill })
            else {
                throw DomainError.notFound
            }
            return SplitQRReview(
                splitBillId: splitBill.id,
                title: splitBill.title,
                requesterName: "Bình Nguyễn",
                amount: Int64(splitBill.totalAmount.amount),
                currency: splitBill.currency,
                perPersonAmount: Int64(splitBill.perPersonAmount.amount),
                remainingSlots: splitBill.remainingSlots
            )
        }
    }
#endif
