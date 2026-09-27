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
        case failed(TransferRepositoryError)
    }

    public var pin: String = ""
    public private(set) var state: State = .idle
    public private(set) var receipt: TransferReceipt?

    private let draft: TransferDraft
    private let transferRepository: ITransferRepository

    public init(draft: TransferDraft, transferRepository: ITransferRepository) {
        self.draft = draft
        self.transferRepository = transferRepository
    }

    public var isPinComplete: Bool {
        pin.count == 4
    }

    // MARK: - Keypad input

    // Input comes from the custom NumericKeypadTray, not the system
    // keyboard - these are its only entry points into `pin`.
    public func appendDigit(_ digit: Int) {
        guard pin.count < 4 else { return }
        pin.append(String(digit))
    }

    public func deleteLast() {
        guard !pin.isEmpty else { return }
        pin.removeLast()
    }

    public var errorMessage: String? {
        guard case .failed(let error) = state else { return nil }
        switch error {
        case .accountNotFound:
            return "This account could not be found."
        case .insufficientBalance:
            return "Insufficient balance in your SplitPay wallet to complete this \(draft.amount.formatted) VND transfer. Please top up or try again."
        case .invalidAmount:
            return "This amount isn't valid."
        case .invalidPin:
            return "Incorrect PIN. Please try again."
        case .network:
            return "Check your connection and try again."
        case .transferFailed, .unknown:
            return "Something went wrong. Please try again."
        }
    }

    // This is meant to be the one real network call in the whole flow —
    // Input and Confirm only ever collect intent. For now it's gated by
    // TestPIN instead of actually calling transferRepository, since there's
    // no real backend running yet to submit to. Remove the guard (and the
    // synthesized receipt) once one exists.
    public func submit() async {
        guard isPinComplete, state != .verifying else { return }

        state = .verifying

        guard pin == TestPIN.value else {
            state = .failed(.invalidPin)
            return
        }

        receipt = TransferReceipt(
            id: UUID().uuidString,
            receiverAccountNumber: draft.receiverAccountNumber,
            receiverHolderName: draft.receiverHolderName,
            amount: draft.amount,
            description: draft.description,
            createdAt: Date(),
            status: "completed"
        )
        state = .idle
    }

    public func retry() {
        pin = ""
        state = .idle
    }
}
