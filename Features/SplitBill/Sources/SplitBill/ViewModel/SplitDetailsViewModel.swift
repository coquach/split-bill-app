//
//  SplitDetailsViewModel.swift
//  SplitBill
//
//  Created by Dinh Long on 28/9/26.
//

import Domains
import Foundation
import Observation

@MainActor
@Observable
public final class SplitDetailsViewModel {

    public struct Loaded: Equatable {
        public let detail: SplitBillDetail
        public let paidRepayments: [Repayment]
    }

    public enum State: Equatable {
        case loading
        case loaded(Loaded)
        case failed(DomainError)
    }

    public private(set) var state: State = .loading

    private let splitBillId: UUID
    private let splitBillRepository: ISplitBillRepository
    private let repaymentRepository: IRepaymentRepository

    public init(
        splitBillId: UUID,
        splitBillRepository: ISplitBillRepository,
        repaymentRepository: IRepaymentRepository
    ) {
        self.splitBillId = splitBillId
        self.splitBillRepository = splitBillRepository
        self.repaymentRepository = repaymentRepository
    }

    public func load() async {
        state = .loading

        do {
            let detail = try await splitBillRepository.getSplitBillDetail(
                id: splitBillId
            )
            let repayments = try await repaymentRepository.getRepayments(
                splitBillId: splitBillId
            )

            // A failed or refunded repayment isn't a payment, so it must not
            // appear in the paid list or count toward progress.
            let paid = repayments.filter { $0.status == .success }

            state = .loaded(Loaded(detail: detail, paidRepayments: paid))
        } catch let error as DomainError {
            state = .failed(error)
        } catch {
            state = .failed(
                .unknown(code: nil, message: error.localizedDescription)
            )
        }
    }

    // MARK: - Derived figures

    /// Always recomputed from `requiredSlots - paidCount`, never stored.
    /// There is no record of *who* hasn't paid — the QR is open to anyone
    /// holding it — so a count is the only honest thing to show.
    public func pendingCount(_ loaded: Loaded) -> Int {
        max(loaded.detail.splitBill.requiredSlots - loaded.paidRepayments.count, 0)
    }

    public func progress(_ loaded: Loaded) -> Double {
        let required = loaded.detail.splitBill.requiredSlots
        guard required > 0 else { return 0 }
        return Double(loaded.paidRepayments.count) / Double(required)
    }

    /// Summed from the actual repayments rather than
    /// `paidSlots × perPersonAmount`, so a partial or adjusted repayment
    /// can't silently overstate what's been collected.
    public func collected(_ loaded: Loaded) -> Amount {
        Amount(loaded.paidRepayments.reduce(0) { $0 + $1.amount.amount })
    }

    public func remaining(_ loaded: Loaded) -> Amount {
        let perPerson = loaded.detail.splitBill.perPersonAmount.amount
        return Amount(Double(pendingCount(loaded)) * perPerson)
    }

    public func statusText(_ loaded: Loaded) -> String {
        switch loaded.detail.splitBill.status {
        case .active: return "Split active"
        case .closed: return "Settled"
        case .expired: return "Expired"
        case .cancelled: return "Cancelled"
        }
    }

    public var errorMessage: String? {
        guard case .failed(let error) = state else { return nil }
        return error.message
    }

    // MARK: - Formatting

    private static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    public func paidAtText(_ repayment: Repayment) -> String? {
        guard let paidAt = repayment.paidAt else { return nil }
        return Self.timestampFormatter.string(from: paidAt)
    }

    public func paidAtText(from date: Date) -> String {
        Self.timestampFormatter.string(from: date)
    }

    public func money(_ amount: Amount) -> String {
        "\(amount.formatted(maximumFractionDigits: SplitCalculator.fractionDigits)) VND"
    }
}
