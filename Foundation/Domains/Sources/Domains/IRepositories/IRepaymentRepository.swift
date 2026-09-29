//
//  IRepaymentRepository.swift
//  Domains
//
//  Created by Co Quach on 27/9/26.
//

import Foundation

public protocol IRepaymentRepository: Sendable {
    func createQRRepayment(_ command: CreateQRRepaymentCommand) async throws -> QRRepaymentReceipt
    func getRepayments(splitBillId: UUID) async throws -> [Repayment]
    func getMyRepaymentRecords() async throws -> [RepaymentRecord]
}
