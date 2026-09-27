//
//  OTPVerificationViewModel.swift
//  Transfer
//
//  Created by Dinh Long on 26/9/26.
//

import Domains
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
        pin.count == 6
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

    // This is the one real network call in the whole flow — Input and
    // Confirm only ever collect intent.
    public func submit() async {
        guard isPinComplete, state != .verifying else { return }

        state = .verifying

        do {
            receipt = try await transferRepository.submitTransfer(draft, pin: pin)
            state = .idle
        } catch let error as TransferRepositoryError {
            state = .failed(error)
        } catch {
            state = .failed(.unknown)
        }
    }

    public func retry() {
        pin = ""
        state = .idle
    }
}
