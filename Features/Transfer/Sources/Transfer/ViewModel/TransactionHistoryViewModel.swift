//
//  TransactionHistoryViewModel.swift
//  Transfer
//
//  Created by Dinh Long on 29/9/26.
//

import Domains
import Foundation
import Observation

@MainActor
@Observable
public final class TransactionHistoryViewModel {

    public struct Section: Identifiable, Equatable {
        public var id: String { title }
        public let title: String
        public let items: [TransferHistory]
    }

    public enum State: Equatable {
        case loading
        case loaded([Section])
        case failed(DomainError)
    }

    public private(set) var state: State = .loading
    public private(set) var selectedFilter: TransactionTypeFilter = .all

    private let transferRepository: ITransferRepository
    // Injected so tests can pin the calendar instead of racing the real
    // clock (midnight boundaries, timezone drift). Defaults to .current.
    private let calendar: Calendar

    public init(
        transferRepository: ITransferRepository,
        calendar: Calendar = .current
    ) {
        self.transferRepository = transferRepository
        self.calendar = calendar
    }

    public func load() async {
        state = .loading

        do {
            let items = try await transferRepository.getTransfers(
                page: 1,
                pageSize: 50,
                filter: selectedFilter
            )
            state = .loaded(group(items))
        } catch let error as DomainError {
            state = .failed(error)
        } catch {
            state = .failed(.unknown(code: nil, message: error.localizedDescription))
        }
    }

    public func selectFilter(_ filter: TransactionTypeFilter) async {
        guard filter != selectedFilter else { return }
        selectedFilter = filter
        await load()
    }

    public func label(for filter: TransactionTypeFilter) -> String {
        switch filter {
        case .all: return "All"
        case .transfer: return "Transfer"
        case .repayment: return "Repayment"
        }
    }

    // Groups by calendar day, newest first, preserving the server's ordering.
    private func group(_ items: [TransferHistory]) -> [Section] {
        var order: [Date] = []
        var buckets: [Date: [TransferHistory]] = [:]

        for item in items {
            let day = calendar.startOfDay(for: item.createdAt)
            if buckets[day] == nil {
                buckets[day] = []
                order.append(day)
            }
            buckets[day]?.append(item)
        }

        return order.map { Section(title: title(for: $0), items: buckets[$0] ?? []) }
    }

    private func title(for day: Date) -> String {
        if calendar.isDateInToday(day) { return "Today" }
        if calendar.isDateInYesterday(day) { return "Yesterday" }
        return Self.dayFormatter.string(from: day)
    }

    // MARK: - Row presentation

    public func title(for item: TransferHistory) -> String {
        item.counterpartyName ?? item.counterpartyWalletNumber ?? "Unknown"
    }

    public func subtitle(for item: TransferHistory) -> String {
        let kind = item.isRepayment ? "Split payment" : "Transfer"
        return "\(kind) · \(Self.timeFormatter.string(from: item.createdAt))"
    }

    public func amountText(for item: TransferHistory) -> String {
        let sign = item.direction == .received ? "+" : "-"
        // The app only ever deals in VND - always show that instead of the
        // raw currency column, which has held stray non-code values.
        return "\(sign)\(Amount(Double(item.amount)).formatted) VND"
    }

    public func isIncoming(_ item: TransferHistory) -> Bool {
        item.direction == .received
    }

    public var errorMessage: String? {
        guard case .failed(let error) = state else { return nil }
        return error.message
    }

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
}
