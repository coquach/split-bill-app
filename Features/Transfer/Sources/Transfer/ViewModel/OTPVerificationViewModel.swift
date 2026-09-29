//
//  OTPVerificationViewModel.swift
//  Transfer
//
//  Created by Dinh Long on 26/9/26.
//

import Domains
import Foundation
import Observation

@MainActor
@Observable
public final class OTPVerificationViewModel {

    public enum State: Equatable {
        case idle
        case verifying
        case failed(DomainError)
    }

    public var pin: String = ""
    public private(set) var state: State = .idle
    public private(set) var receipt: TransferReceipt?

    private let draft: TransferDraft
    private let transferRepository: ITransferRepository

    private var idempotencyKey = UUID().uuidString

    public init(draft: TransferDraft, transferRepository: ITransferRepository) {
        self.draft = draft
        self.transferRepository = transferRepository
    }

    public var isPinComplete: Bool {
        pin.count == TransferPIN.length
    }

    public var errorMessage: String? {
        guard case .failed(let error) = state else { return nil }
        return error.message
    }

    
    public func submit() async {
        guard isPinComplete, state != .verifying else { return }

        state = .verifying

        let command = CreateTransferCommand(
            recipientWalletId: draft.receiverWalletId,

            amount: Int64(draft.amount.amount.rounded()),
            description: draft.description.isEmpty ? nil : draft.description,
            pin: pin,
            idempotencyKey: idempotencyKey
        )

        do {
            let transaction = try await transferRepository.createTransfer(command)
            receipt = TransferReceipt(transaction: transaction, draft: draft)
            state = .idle
        } catch let error as DomainError {
            handleFailure(error)
        } catch {
            handleFailure(.unknown(code: nil, message: error.localizedDescription))
        }
    }

    private func handleFailure(_ error: DomainError) {
    
        switch error {
        case .invalidPin, .invalidPinFormat, .pinLocked, .validation,
             .insufficientBalance:
            idempotencyKey = UUID().uuidString
        default:
            break
        }

        state = .failed(error)
    }

    public func retry() {
        pin = ""
        state = .idle
    }
}
