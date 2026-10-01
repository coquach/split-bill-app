//
//  MockTransferRepository.swift
//  HomeTests
//

import Domains
import Foundation

final class MockTransferRepository: ITransferRepository, @unchecked Sendable {
    var transfers: [TransferHistory] = []
    var error: Error?

    private(set) var getTransfersCalls = 0
    private(set) var lastPage: Int?
    private(set) var lastPageSize: Int?
    private(set) var lastFilter: TransactionTypeFilter?

    func createTransfer(_ command: CreateTransferCommand) async throws -> TransferTransaction {
        throw DomainError.notFound
    }

    func getTransfers(
        page: Int,
        pageSize: Int,
        filter: TransactionTypeFilter
    ) async throws -> [TransferHistory] {
        getTransfersCalls += 1
        lastPage = page
        lastPageSize = pageSize
        lastFilter = filter
        if let error { throw error }
        return transfers
    }

    func getTransfer(id: UUID) async throws -> TransferDetail {
        throw DomainError.notFound
    }
}
