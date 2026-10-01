//
//  TransactionDetailViewModel.swift
//  Transfer
//
//  Created by Dinh Long on 28/9/26.
//

import Domains
import Foundation
import Observation

@MainActor
@Observable
public final class TransactionDetailViewModel {

    public enum State: Equatable {
        case loading
        case loaded(TransferDetail)
        case failed(DomainError)
    }

    public private(set) var state: State = .loading

    public let receiverHolderName: String
    /// Whether the viewer sent this transaction — the amount renders with a
    /// minus and error styling when true, plus/success when false. Mirrors
    /// the sign and colour the history list shows for the same transfer.
    public let isOutgoing: Bool

    private let transactionId: UUID
    private let transferRepository: ITransferRepository

    public init(
        transactionId: UUID,
        receiverHolderName: String,
        isOutgoing: Bool,
        transferRepository: ITransferRepository
    ) {
        self.transactionId = transactionId
        self.receiverHolderName = receiverHolderName
        self.isOutgoing = isOutgoing
        self.transferRepository = transferRepository
    }

    public func load() async {
        state = .loading

        do {
            let detail = try await transferRepository.getTransfer(
                id: transactionId
            )
            state = .loaded(detail)
        } catch let error as DomainError {
            state = .failed(error)
        } catch {
            state = .failed(
                .unknown(code: nil, message: error.localizedDescription)
            )
        }
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

    public func formattedDate(_ date: Date) -> String {
        let day = Self.dayFormatter.string(from: date)
        let time = Self.timeFormatter.string(from: date)
        return "\(day) · \(time)"
    }

    public func formattedAmount(_ amount: Int64) -> String {
        let sign = isOutgoing ? "-" : "+"
        return "\(sign)\(Amount(Double(amount)).formatted) VND"
    }
}
