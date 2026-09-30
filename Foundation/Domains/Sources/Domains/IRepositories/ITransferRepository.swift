//
//  ITransferRepository.swift
//  Domains
//
//  Created by Co Quach on 27/9/26.
//

import Foundation

public enum TransactionTypeFilter : String, Encodable, Sendable, Equatable, Hashable, CaseIterable {
    case all = "ALL";
    case transfer = "TRANSFER";
    case repayment = "REPAYMENT"
}

public protocol ITransferRepository: Sendable {
    func createTransfer(_ command: CreateTransferCommand) async throws -> TransferTransaction
    func getTransfers(page: Int, pageSize: Int, filter: TransactionTypeFilter) async throws -> [TransferHistory]
    func getTransfer(id: UUID) async throws -> TransferDetail
}
