//
//  ITransferRepository.swift
//  Domains
//
//  Created by Dinh Long on 26/9/26.
//

import Foundation

public enum TransferRepositoryError: Error, Sendable, Equatable {
    case accountNotFound
    case insufficientBalance
    case invalidAmount
    /// The transaction PIN entered on the OTP step didn't match.
    case invalidPin
    case transferFailed
    case network
    case unknown
}

public protocol ITransferRepository: Sendable {
    /// Submits a transfer for real. `pin` is the account's transaction
    /// PIN (set at sign-up), checked here since this is the one call
    /// that actually moves money — never verified on-device.
    func submitTransfer(_ draft: TransferDraft, pin: String) async throws -> TransferReceipt
}
