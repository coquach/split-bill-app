//
//  ITransferRepository.swift
//  Domains
//
//  Created by Co Quach on 27/9/26.
//

import Foundation

public protocol ITransferRepository: Sendable {
    func createTransfer(_ command: CreateTransferCommand) async throws -> TransferTransaction
    func getTransfers() async throws -> [TransferTransaction]
    func getTransfer(id: UUID) async throws -> TransferTransaction
}
