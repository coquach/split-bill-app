//
//  ITransferRepository.swift
//  Domains
//
//  Created by Co Quach on 27/9/26.
//

import Foundation

public protocol ITransferRepository: Sendable {
    /// Calls the `create_transfer` RPC. The PIN travels with the command and
    /// is verified server-side — the app never decides whether a PIN is
    /// correct, it only collects it.
    func createTransfer(
        _ command: CreateTransferCommand
    ) async throws -> TransferResult

    /// Calls the `get_transfer_detail` RPC.
    func getTransferDetail(id: UUID) async throws -> TransferDetail
}
