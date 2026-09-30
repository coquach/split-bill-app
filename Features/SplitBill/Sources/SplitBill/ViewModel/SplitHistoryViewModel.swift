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

    // The filter under the tabs. Inactive = settled, expired or cancelled.
    public enum Filter: String, CaseIterable, Hashable {
        case active = "Active"
        case inactive = "Inactive"
    }

    public private(set) var state: State = .loading
    public var selectedKind: Kind = .yourSplit
    public var selectedFilter: Filter = .active

    private let splitBillRepository: ISplitBillRepository

    public init(splitBillRepository: ISplitBillRepository) {
        self.splitBillRepository = splitBillRepository
    }

    public func load() async {
        state = .loading

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
            state = .failed(error)
        } catch {
            state = .failed(
                .unknown(code: nil, message: error.localizedDescription)
            )
        }
    }

    // Everything is already loaded, so switching tab or filter is a local pick - no refetch needed.
    public var visibleBills: [SplitBillListItem] {
        guard case .loaded(let created, let transferred) = state else { return [] }

        let bills = selectedKind == .yourSplit ? created : transferred

        switch selectedFilter {
        case .active:
            return bills.filter { $0.status == .active }
        case .inactive:
            return bills.filter { $0.status != .active }
        }
    }

    public func select(_ kind: Kind) {
        selectedKind = kind
    }

    public func select(_ filter: Filter) {
        selectedFilter = filter
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
