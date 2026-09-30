//
//  MockSplitBillRepository.swift
//  SplitPay
//

#if DEBUG
    import Domains
    import Foundation

    final nonisolated class MockSplitBillRepository: ISplitBillRepository, @unchecked Sendable {
        private let store: MockAppStore
        private var repaidSplitBillIds: Set<UUID> = []

        private(set) var createSplitBillCalls = 0
        private(set) var lastCreateCommand: CreateSplitBillCommand?

        init(store: MockAppStore) {
            self.store = store
        }

        func createSplitBill(_ command: CreateSplitBillCommand) async throws -> SplitBill {
            createSplitBillCalls += 1
            lastCreateCommand = command

            guard let source = store.transfers.first(where: { $0.id == command.sourceTransferId }) else {
                throw DomainError.invalidSourceTransfer
            }

            let result = SplitCalculator.equalSplit(
                totalAmount: Amount(Double(source.amount)),
                participantCount: command.participantCount
            )
            let now = Date()
            let splitBill = SplitBill(
                id: UUID(),
                requesterId: store.user.id,
                sourceTransferId: source.id,
                title: command.title,
                note: command.note,
                totalAmount: Amount(Double(source.amount)),
                currency: source.currency,
                participantCount: max(command.participantCount, 2),
                perPersonAmount: result.perPersonAmount,
                requesterAmount: result.requesterAmount,
                requiredSlots: result.requiredSlots,
                paidSlots: 0,
                remainingSlots: result.requiredSlots,
                status: .active,
                expiresAt: Calendar.current.date(byAdding: .day, value: command.expiryDays, to: now),
                closedAt: nil,
                createdAt: now,
                updatedAt: now
            )
            store.updateSplitBill(splitBill)
            return splitBill
        }

        func getSplitBills(
            role: SplitBillRoleFilter,
            status: SplitBillStatusFilter,
            page: Int,
            pageSize: Int
        ) async throws -> SplitBillPage {
            if UITestConfig.scenario == .historyFails {
                throw DomainError.unknown(code: "UITEST", message: "Split history fetch failed")
            }

            var items = store.splitBills
            switch role {
            case .created:
                items = items.filter { $0.requesterId == store.user.id }
            case .repaid:
                items = items.filter { repaidSplitBillIds.contains($0.id) }
            }

            if status != .all {
                items = items.filter { bill in
                    switch status {
                    case .all: true
                    case .active: bill.status == .active
                    case .closed: bill.status == .closed || bill.status == .cancelled
                    case .expired: bill.status == .expired
                    }
                }
            }

            let listItems = items.map { listItem(for: $0) }
            return SplitBillPage(
                items: listItems,
                totalCount: Int64(listItems.count),
                page: page,
                pageSize: pageSize
            )
        }

        func getSplitBill(id: UUID) async throws -> SplitBill {
            guard let splitBill = store.splitBills.first(where: { $0.id == id }) else {
                throw DomainError.notFound
            }
            return splitBill
        }

        func getSplitBillDetail(id: UUID) async throws -> SplitBillDetail {
            guard let splitBill = store.splitBills.first(where: { $0.id == id }) else {
                throw DomainError.notFound
            }
            let isRequester = splitBill.requesterId == store.user.id
            let canRepay = splitBill.status == .active
                && !isRequester
                && !repaidSplitBillIds.contains(splitBill.id)
                && splitBill.remainingSlots > 0
            return SplitBillDetail(
                splitBill: splitBill,
                transferStatus: .success,
                transactionRef: "TRX-SOURCE",
                qrId: isRequester ? UUID() : nil,
                qrPayload: isRequester ? UITestSeedData.validQRPayload : nil,
                qrImageURL: nil,
                qrIsActive: isRequester ? true : nil,
                qrExpiresAt: splitBill.expiresAt,
                isRequester: isRequester,
                hasRepaid: repaidSplitBillIds.contains(splitBill.id),
                canUpdate: isRequester && splitBill.status == .active,
                canClose: isRequester && splitBill.status == .active,
                canRepay: canRepay
            )
        }

        func updateSplitBill(_ command: UpdateSplitBillCommand) async throws -> SplitBill {
            guard var splitBill = store.splitBills.first(where: { $0.id == command.splitBillId }) else {
                throw DomainError.notFound
            }
            if let title = command.title {
                splitBill = renamed(splitBill, title: title)
            }
            store.updateSplitBill(splitBill)
            return splitBill
        }

        func closeSplitBill(id: UUID) async throws -> SplitBill {
            guard let splitBill = store.splitBills.first(where: { $0.id == id }) else {
                throw DomainError.notFound
            }
            let closed = SplitBill(
                id: splitBill.id,
                requesterId: splitBill.requesterId,
                sourceTransferId: splitBill.sourceTransferId,
                title: splitBill.title,
                note: splitBill.note,
                totalAmount: splitBill.totalAmount,
                currency: splitBill.currency,
                participantCount: splitBill.participantCount,
                perPersonAmount: splitBill.perPersonAmount,
                requesterAmount: splitBill.requesterAmount,
                requiredSlots: splitBill.requiredSlots,
                paidSlots: splitBill.paidSlots,
                remainingSlots: 0,
                status: .closed,
                expiresAt: splitBill.expiresAt,
                closedAt: Date(),
                createdAt: splitBill.createdAt,
                updatedAt: Date()
            )
            store.updateSplitBill(closed)
            return closed
        }

        /// `SplitBill` has no mutable properties, so rebuild with a new title.
        private func renamed(_ bill: SplitBill, title: String) -> SplitBill {
            SplitBill(
                id: bill.id,
                requesterId: bill.requesterId,
                sourceTransferId: bill.sourceTransferId,
                title: title,
                note: bill.note,
                totalAmount: bill.totalAmount,
                currency: bill.currency,
                participantCount: bill.participantCount,
                perPersonAmount: bill.perPersonAmount,
                requesterAmount: bill.requesterAmount,
                requiredSlots: bill.requiredSlots,
                paidSlots: bill.paidSlots,
                remainingSlots: bill.remainingSlots,
                status: bill.status,
                expiresAt: bill.expiresAt,
                closedAt: bill.closedAt,
                createdAt: bill.createdAt,
                updatedAt: bill.updatedAt
            )
        }

        private func listItem(for bill: SplitBill) -> SplitBillListItem {
            SplitBillListItem(
                id: bill.id,
                requesterId: bill.requesterId,
                sourceTransferId: bill.sourceTransferId,
                title: bill.title,
                note: bill.note,
                totalAmount: Int64(bill.totalAmount.amount),
                currency: bill.currency,
                participantCount: bill.participantCount,
                perPersonAmount: Int64(bill.perPersonAmount.amount),
                requesterAmount: Int64(bill.requesterAmount.amount),
                requiredSlots: bill.requiredSlots,
                paidSlots: bill.paidSlots,
                status: bill.status,
                expiresAt: bill.expiresAt,
                closedAt: bill.closedAt,
                createdAt: bill.createdAt,
                isRequester: bill.requesterId == store.user.id,
                hasRepaid: repaidSplitBillIds.contains(bill.id)
            )
        }
    }
#endif
