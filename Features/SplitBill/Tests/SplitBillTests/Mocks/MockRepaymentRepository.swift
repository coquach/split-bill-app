//
//  MockRepaymentRepository.swift
//  SplitBillTests
//

import Domains
import Foundation

final class MockRepaymentRepository: IRepaymentRepository, @unchecked Sendable {
    var receipt: QRRepaymentReceipt?
    var repayments: [Repayment] = []
    var error: Error?

    // Gates the repayment call so a test can hold it mid-flight and probe
    // the view model's reentrancy guard.
    var holdCreateRepayment = false
    private var createContinuation: CheckedContinuation<Void, Never>?

    func resumeCreateRepayment() {
        createContinuation?.resume()
        createContinuation = nil
    }

    private(set) var createQRRepaymentCalls = 0
    private(set) var lastCreateCommand: CreateQRRepaymentCommand?
    private(set) var getRepaymentsCalls = 0
    private(set) var lastRepaymentsSplitBillId: UUID?

    func createQRRepayment(_ command: CreateQRRepaymentCommand) async throws -> QRRepaymentReceipt {
        createQRRepaymentCalls += 1
        lastCreateCommand = command
        if holdCreateRepayment {
            await withCheckedContinuation { createContinuation = $0 }
        }
        if let error { throw error }
        guard let receipt else { throw DomainError.notFound }
        return receipt
    }

    func getRepayments(splitBillId: UUID) async throws -> [Repayment] {
        getRepaymentsCalls += 1
        lastRepaymentsSplitBillId = splitBillId
        if let error { throw error }
        return repayments
    }
}
