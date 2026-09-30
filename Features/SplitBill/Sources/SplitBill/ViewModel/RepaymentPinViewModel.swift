//
//  RepaymentPinViewModel.swift
//  SplitBill
//
//  Created by Dinh Long on 29/9/26.
//

import Domains
import Foundation
import Observation

@MainActor
@Observable
public final class RepaymentPinViewModel {

    public enum State: Equatable {
        case idle
        case submitting
        case failed(DomainError)
    }

    public let scanned: ScannedRepayment
    public var pin: String = ""
    public private(set) var state: State = .idle
    public private(set) var receipt: QRRepaymentReceipt?

    private let repaymentRepository: IRepaymentRepository
    private var idempotencyKey = UUID().uuidString

    public init(scanned: ScannedRepayment, repaymentRepository: IRepaymentRepository) {
        self.scanned = scanned
        self.repaymentRepository = repaymentRepository
    }

    public var isPinComplete: Bool {
        pin.count == 6
    }

    public var errorMessage: String? {
        guard case .failed(let error) = state else { return nil }
        return error.message
    }

    public func submit() async {
        guard isPinComplete, state != .submitting else { return }

        state = .submitting

        let command = CreateQRRepaymentCommand(
            qrPayload: scanned.payload,
            pin: pin,
            note: nil,
            idempotencyKey: idempotencyKey
        )

        do {
            receipt = try await repaymentRepository.createQRRepayment(command)
            state = .idle
            NotificationCenter.default.post(name: .transactionsDidChange, object: nil)
        } catch let error as DomainError {
            handleFailure(error)
        } catch {
            handleFailure(.unknown(code: nil, message: error.localizedDescription))
        }
    }

    private func handleFailure(_ error: DomainError) {
        // A rejected PIN/amount moved no money, so the next try needs a fresh key; network/unknown failures keep it, so a retry can't double-pay.
        switch error {
        case .invalidPin, .invalidPinFormat, .pinLocked, .validation, .insufficientBalance:
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
