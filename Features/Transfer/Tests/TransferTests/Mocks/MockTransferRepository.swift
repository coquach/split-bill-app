//
//  MockTransferRepository.swift
//  TransferTests
//

import Domains
import Foundation

final class MockTransferRepository: ITransferRepository, @unchecked Sendable {
    var transfer: TransferTransaction?
    var transfers: [TransferHistory] = []
    var detail: TransferDetail?
    var error: Error?

    private(set) var createTransferCalls = 0
    private(set) var lastCreateCommand: CreateTransferCommand?
    private(set) var getTransfersCalls = 0
    private(set) var lastFilter: TransactionTypeFilter?
    private(set) var getTransferCalls = 0

    func createTransfer(_ command: CreateTransferCommand) async throws -> TransferTransaction {
        createTransferCalls += 1
        lastCreateCommand = command
        if let error { throw error }
        guard let transfer else {
            throw DomainError.notFound
        }
        return transfer
    }

    func getTransfers(
        page: Int,
        pageSize: Int,
        filter: TransactionTypeFilter
    ) async throws -> [TransferHistory] {
        getTransfersCalls += 1
        lastFilter = filter
        if let error { throw error }
        return transfers
    }

    func getTransfer(id: UUID) async throws -> TransferDetail {
        getTransferCalls += 1
        if let error { throw error }
        guard let detail else {
            throw DomainError.notFound
        }
        return detail
    }
}
