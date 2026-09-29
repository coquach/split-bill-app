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
        case loaded(active: [SplitBillListItem], settled: [SplitBillListItem])
        case failed(DomainError)
    }

    public private(set) var state: State = .loading

    private let splitBillRepository: ISplitBillRepository

    public init(splitBillRepository: ISplitBillRepository) {
        self.splitBillRepository = splitBillRepository
    }

    public func load() async {
        state = .loading

        do {
            // `.created` = splits this user requested, not ones they paid into.
            let page = try await splitBillRepository.getSplitBills(
                role: .created,
                status: .all,
                page: 1,
                pageSize: 50
            )
            let bills = page.items

            let active = bills.filter { $0.status == .active }
            let settled = bills.filter { $0.status != .active }

            state = .loaded(active: active, settled: settled)
        } catch let error as DomainError {
            state = .failed(error)
        } catch {
            state = .failed(
                .unknown(code: nil, message: error.localizedDescription)
            )
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
