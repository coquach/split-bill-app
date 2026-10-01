//
//  SplitHistoryViewModel.swift
//  SplitBill
//
//  Created by Dinh Long on 28/9/26.
//

import Domains
import Foundation
import Observation

@MainActor
@Observable
public final class SplitHistoryViewModel {

    public enum State: Equatable {
        case loading
        case loaded(created: [SplitBillListItem], transferred: [SplitBillListItem])
        case failed(DomainError)
    }

    // The two main tabs: splits you created, and splits you paid into by scanning their QR.
    public enum Kind: String, CaseIterable, Hashable {
        case yourSplit = "Your Split"
        case splitTransfer = "Split Transfer"
    }

    // The filter under the tabs reuses the status filter declared on the
    // repository contract (SplitBillStatusFilter): All / Active / Settled /
    // Expired. Cancelled bills only show up under All — the declared filter
    // has no separate case for them.
    public private(set) var state: State = .loading
    public var selectedKind: Kind = .yourSplit
    public var selectedFilter: SplitBillStatusFilter = .all

    private let splitBillRepository: ISplitBillRepository
    private let notificationCenter: NotificationCenter
    // nonisolated(unsafe): written once in init, read only in deinit (which
    // runs outside the MainActor) — no concurrent access is possible.
    nonisolated(unsafe) private var transactionsObserver: NSObjectProtocol?

    public init(
        splitBillRepository: ISplitBillRepository,
        notificationCenter: NotificationCenter = .default
    ) {
        self.splitBillRepository = splitBillRepository
        self.notificationCenter = notificationCenter

        // Paying into a split changes its paid slots, so reload when a repayment finishes
        transactionsObserver = notificationCenter.addObserver(
            forName: .transactionsDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                await self?.load(showsSpinner: false)
            }
        }
    }

    deinit {
        if let transactionsObserver {
            notificationCenter.removeObserver(transactionsObserver)
        }
    }

    // showsSpinner: false keeps the current lists on screen while the new ones load
    public func load(showsSpinner: Bool = true) async {
        if showsSpinner {
            state = .loading
        }

        do {
            // Both requests start together; each one asks for a different role.
            async let createdPage = splitBillRepository.getSplitBills(
                role: .created,
                status: .all,
                page: 1,
                pageSize: 50
            )
            async let transferredPage = splitBillRepository.getSplitBills(
                role: .repaid,
                status: .all,
                page: 1,
                pageSize: 50
            )

            let (created, transferred) = try await (createdPage, transferredPage)

            state = .loaded(created: created.items, transferred: transferred.items)
        } catch let error as DomainError {
            if showsSpinner { state = .failed(error) }
        } catch {
            if showsSpinner {
                state = .failed(
                    .unknown(code: nil, message: error.localizedDescription)
                )
            }
        }
    }

    // Everything is already loaded, so switching tab or filter is a local pick - no refetch needed.
    public var visibleBills: [SplitBillListItem] {
        guard case .loaded(let created, let transferred) = state else { return [] }

        let bills = selectedKind == .yourSplit ? created : transferred

        switch selectedFilter {
        case .all:
            return bills
        case .active:
            return bills.filter { $0.status == .active }
        case .closed:
            return bills.filter { $0.status == .closed }
        case .expired:
            return bills.filter { $0.status == .expired }
        }
    }

    public func select(_ kind: Kind) {
        selectedKind = kind
    }

    public func select(_ filter: SplitBillStatusFilter) {
        selectedFilter = filter
    }

    // Chip label for a filter — "Settled" matches the badge wording for
    // closed bills (see statusText(for:)).
    public func label(for filter: SplitBillStatusFilter) -> String {
        switch filter {
        case .all: return "All"
        case .active: return "Active"
        case .closed: return "Settled"
        case .expired: return "Expired"
        }
    }

    public func subtitle(for bill: SplitBillListItem) -> String {
        "\(bill.paidSlots) of \(bill.requiredSlots) paid"
    }

    public func amountText(for bill: SplitBillListItem) -> String {
        "\(Amount(Double(bill.totalAmount)).formatted) VND"
    }

    public func statusText(for bill: SplitBillListItem) -> String {
        switch bill.status {
        case .active: return "Active"
        case .closed: return "Settled"
        case .expired: return "Expired"
        case .cancelled: return "Cancelled"
        }
    }

    public var errorMessage: String? {
        guard case .failed(let error) = state else { return nil }
        return error.message
    }
}
