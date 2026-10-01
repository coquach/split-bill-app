//
//  UITestSeedData.swift
//  SplitPay
//
//  Canned in-memory data for UI test runs. Assertions in SplitPayUITests
//  are written against these exact values, so treat changes here as test
//  changes.
//

#if DEBUG
    import Domains
    import Foundation

    nonisolated struct UITestSeedData {
        let user: User
        let profile: Profile
        let wallet: Wallet
        let pinIsSet: Bool
        let transfers: [TransferHistory]
        let splitBills: [SplitBill]
        let repayments: [Repayment]

        /// The well-known account number the Transfer-input lookup resolves to.
        static let recipientAccountNumber = "0123456789"
        static let recipientHolderName = "Trần Mai"
        /// Magic account number that makes the lookup fail.
        static let unknownAccountNumber = "000000"
        /// Magic credentials that make sign in / sign up fail.
        static let failingEmail = "fail@test.com"
        /// Magic PIN that makes verifyPin fail.
        static let failingPin = "000000"
        /// The QR payload `decodeQR` resolves to the active split bill below.
        static let validQRPayload = "UITEST-QR"
        /// Magic payload that makes decodeQR throw.
        static let failingQRPayload = "UITEST-QR-FAIL"

        private static let now = Date()

        static func load(_ dataSet: UITestDataSet) -> UITestSeedData {
            let user = makeUser()
            switch dataSet {
            case .empty:
                return UITestSeedData(
                    user: user,
                    profile: makeProfile(),
                    wallet: makeWallet(),
                    pinIsSet: true,
                    transfers: [],
                    splitBills: [],
                    repayments: []
                )
            case .default:
                return rich(user: user)
            }
        }

        // MARK: - Datasets

        private static func rich(user: User) -> UITestSeedData {
            UITestSeedData(
                user: user,
                profile: makeProfile(),
                wallet: makeWallet(),
                pinIsSet: true,
                transfers: [
                    makeTransfer(
                        id: UITestSeedData.UITestIDs.transferSplitCandidate,
                        counterpartyName: recipientHolderName,
                        counterpartyWalletNumber: recipientAccountNumber,
                        direction: .sent,
                        amount: 1_200_000,
                        description: "Team lunch",
                        daysAgo: 1
                    ),
                    makeTransfer(
                        id: UUID(),
                        counterpartyName: "Phạm Đức",
                        counterpartyWalletNumber: "0987654321",
                        direction: .received,
                        amount: 300_000,
                        description: "Movie tickets",
                        daysAgo: 2,
                        isRepayment: true
                    ),
                    makeTransfer(
                        id: UUID(),
                        counterpartyName: "Vũ Hà",
                        counterpartyWalletNumber: "0908080707",
                        direction: .sent,
                        amount: 85000,
                        description: "Coffee run",
                        daysAgo: 3
                    )
                ],
                splitBills: [
                    makeSplitBill(
                        id: UITestSeedData.UITestIDs.activeSplitBill,
                        requesterId: user.id,
                        title: "Team Lunch",
                        totalAmount: 1_200_000,
                        participantCount: 4,
                        paidSlots: 1,
                        status: .active
                    ),
                    makeSplitBill(
                        id: UUID(),
                        requesterId: user.id,
                        title: "Movie Night",
                        totalAmount: 300_000,
                        participantCount: 2,
                        paidSlots: 1,
                        status: .closed
                    )
                ],
                repayments: [
                    makeRepayment(splitBillTitle: "Team Lunch", amount: 400_000)
                ]
            )
        }

        // MARK: - Stable IDs the UI tests assert against

        enum UITestIDs {
            static let activeSplitBill = UUID(uuidString: "AAAAAAAA-0000-0000-0000-000000000001")!
            /// A SENT, non-repayment transfer — the one whose detail screen shows
            /// the "Split Bill" action.
            static let transferSplitCandidate =
                UUID(uuidString: "BBBBBBBB-0000-0000-0000-000000000001")!
        }

        // MARK: - Builders

        private static func makeUser() -> User {
            User(id: UUID(), email: "uitest@splitpay.dev")
        }

        private static func makeProfile() -> Profile {
            Profile(
                id: UUID(),
                fullName: "Bình Nguyễn",
                phoneNumber: "0912345678",
                email: "uitest@splitpay.dev",
                biometricsEnabled: false,
                status: .active,
                createdAt: now,
                updatedAt: now
            )
        }

        private static func makeWallet() -> Wallet {
            Wallet(
                id: UUID(),
                userId: UUID(),
                walletNumber: "1000000001",
                walletHolderName: "Bình Nguyễn",
                isDefault: true,
                status: .active,
                balance: 5_000_000,
                currency: "VND",
                createdAt: now,
                updatedAt: now
            )
        }

        private static func makeTransfer(
            id: UUID,
            counterpartyName: String,
            counterpartyWalletNumber: String,
            direction: TransferDirection,
            amount: Int64,
            description: String,
            daysAgo: Int,
            isRepayment: Bool = false
        ) -> TransferHistory {
            let userId = UUID()
            let walletId = UUID()
            let created = Calendar.current.date(byAdding: .day, value: -daysAgo, to: now)!
            return TransferHistory(
                id: id,
                transactionRef: "TRX\(daysAgo)\(abs(id.hashValue) % 1000)",
                direction: direction,
                senderUserId: direction == .sent ? userId : UUID(),
                senderWalletId: direction == .sent ? walletId : UUID(),
                recipientUserId: direction == .received ? userId : UUID(),
                recipientWalletId: direction == .received ? walletId : UUID(),
                amount: amount,
                fee: 0,
                description: description,
                status: .success,
                currency: "VND",
                counterpartyWalletNumber: counterpartyWalletNumber,
                counterpartyName: counterpartyName,
                completedAt: created,
                createdAt: created,
                isRepayment: isRepayment,
                repaymentId: nil,
                totalCount: 3
            )
        }

        private static func makeSplitBill(
            id: UUID,
            requesterId: UUID,
            title: String,
            totalAmount: Int64,
            participantCount: Int,
            paidSlots: Int,
            status: SplitBillStatus
        ) -> SplitBill {
            let result = SplitCalculator.equalSplit(
                totalAmount: Amount(Double(totalAmount)),
                participantCount: participantCount
            )
            let created = Calendar.current.date(byAdding: .day, value: -1, to: now)!
            return SplitBill(
                id: id,
                requesterId: requesterId,
                sourceTransferId: UITestIDs.transferSplitCandidate,
                title: title,
                note: nil,
                totalAmount: Amount(Double(totalAmount)),
                currency: "VND",
                participantCount: participantCount,
                perPersonAmount: result.perPersonAmount,
                requesterAmount: result.requesterAmount,
                requiredSlots: result.requiredSlots,
                paidSlots: paidSlots,
                remainingSlots: max(result.requiredSlots - paidSlots, 0),
                status: status,
                expiresAt: Calendar.current.date(byAdding: .day, value: 6, to: now),
                closedAt: status == .closed ? now : nil,
                createdAt: created,
                updatedAt: now
            )
        }

        private static func makeRepayment(splitBillTitle: String, amount: Int64) -> Repayment {
            Repayment(
                id: UUID(),
                splitBillId: UITestIDs.activeSplitBill,
                payerUserId: UUID(),
                transferTransactionId: nil,
                paymentMethod: .qrTransfer,
                amount: Amount(Double(amount)),
                currency: "VND",
                payerDisplayName: splitBillTitle + " payer",
                note: nil,
                status: .success,
                idempotencyKey: UUID().uuidString,
                paidAt: now,
                createdAt: now
            )
        }
    }
#endif
