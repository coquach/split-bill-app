//
//  MockSplitBillRepository.swift
//  SplitBillTests
//

import Domains
import Foundation

final class MockSplitBillRepository: ISplitBillRepository, @unchecked Sendable {
    var createdBill: SplitBill?
    var updatedBill: SplitBill?
    var closedBill: SplitBill?
    var detail: SplitBillDetail?
    var pageResult: SplitBillPage?
    // Per-role override — history loads both roles in parallel, so a test
    // can hand each one its own page.
    var pageResultsByRole: [SplitBillRoleFilter: SplitBillPage] = [:]
    var error: Error?

    // Gates the create call so a test can hold it mid-flight and probe
    // the view model's reentrancy guard.
    var holdCreateSplit = false
    private var createContinuation: CheckedContinuation<Void, Never>?

    func resumeCreateSplit() {
        createContinuation?.resume()
        createContinuation = nil
    }

    private(set) var createSplitBillCalls = 0
    private(set) var lastCreateCommand: CreateSplitBillCommand?
    private(set) var updateSplitBillCalls = 0
    private(set) var lastUpdateCommand: UpdateSplitBillCommand?
    private(set) var closeSplitBillCalls = 0
    private(set) var lastClosedId: UUID?
    private(set) var getSplitBillDetailCalls = 0
    private(set) var lastDetailId: UUID?
    private(set) var getSplitBillsCalls = 0
    private(set) var rolesRequested: [SplitBillRoleFilter] = []
    private(set) var lastRole: SplitBillRoleFilter?
    private(set) var lastStatusFilter: SplitBillStatusFilter?
    private(set) var lastPage: Int?
    private(set) var lastPageSize: Int?

    func createSplitBill(_ command: CreateSplitBillCommand) async throws -> SplitBill {
        createSplitBillCalls += 1
        lastCreateCommand = command
        if holdCreateSplit {
            await withCheckedContinuation { createContinuation = $0 }
        }
        if let error { throw error }
        guard let createdBill else { throw DomainError.notFound }
        return createdBill
    }

    func getSplitBills(
        role: SplitBillRoleFilter,
        status: SplitBillStatusFilter,
        page: Int,
        pageSize: Int
    ) async throws -> SplitBillPage {
        getSplitBillsCalls += 1
        rolesRequested.append(role)
        lastRole = role
        lastStatusFilter = status
        lastPage = page
        lastPageSize = pageSize
        if let error { throw error }
        if let rolePage = pageResultsByRole[role] {
            return rolePage
        }
        guard let pageResult else { throw DomainError.notFound }
        return pageResult
    }

    func getSplitBill(id: UUID) async throws -> SplitBill {
        getSplitBillsCalls += 1
        if let error { throw error }
        guard let createdBill else { throw DomainError.notFound }
        return createdBill
    }

    func getSplitBillDetail(id: UUID) async throws -> SplitBillDetail {
        getSplitBillDetailCalls += 1
        lastDetailId = id
        if let error { throw error }
        guard let detail else { throw DomainError.notFound }
        return detail
    }

    func updateSplitBill(_ command: UpdateSplitBillCommand) async throws -> SplitBill {
        updateSplitBillCalls += 1
        lastUpdateCommand = command
        if let error { throw error }
        guard let updatedBill else { throw DomainError.notFound }
        return updatedBill
    }

    func closeSplitBill(id: UUID) async throws -> SplitBill {
        closeSplitBillCalls += 1
        lastClosedId = id
        if let error { throw error }
        guard let closedBill else { throw DomainError.notFound }
        return closedBill
    }
}
