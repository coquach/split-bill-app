//
//  DomainError.swift
//  Domains
//
//  Created by Co Quach on 27/9/26.
//

import Foundation

public enum DomainError: Error, Equatable, Sendable {
    case validation
    case unauthorized
    case forbidden
    case notFound
    case duplicateResource
    case invalidSourceTransfer
    case pinNotSet
    case invalidPinFormat
    case invalidPin
    case pinLocked
    case invalidParticipantCount
    case splitBillLocked
    case splitBillNotCollectable
    case noRemainingRepaymentSlot
    case invalidRepaymentAmount
    case lockedAmountMismatch
    case insufficientBalance
    case idempotencyKeyConflict
    case rateLimitExceeded
    case edgeFunctionError
    case network
    case unknown(code: String?, message: String)

    public var message: String {
        switch self {
        case .validation: return "The submitted data is invalid."
        case .unauthorized: return "Your session is invalid or has expired."
        case .forbidden: return "You are not allowed to perform this action."
        case .notFound: return "The requested resource was not found."
        case .duplicateResource: return "This resource already exists."
        case .invalidSourceTransfer: return "The source transfer is invalid."
        case .pinNotSet: return "Please set up your transaction PIN first."
        case .invalidPinFormat: return "PIN must be exactly 6 digits."
        case .invalidPin: return "The transaction PIN is incorrect."
        case .pinLocked: return "PIN verification is temporarily locked."
        case .invalidParticipantCount:
            return "Participant count must be at least 2."
        case .splitBillLocked: return "This split bill can no longer be edited."
        case .splitBillNotCollectable:
            return "This split bill is no longer collectable."
        case .noRemainingRepaymentSlot: return "No repayment slot remains."
        case .invalidRepaymentAmount: return "The repayment amount is invalid."
        case .lockedAmountMismatch:
            return "The split amount is locked to the source transfer."
        case .insufficientBalance: return "Your wallet balance is insufficient."
        case .idempotencyKeyConflict:
            return "This idempotency key was already used for another request."
        case .rateLimitExceeded:
            return "Too many requests. Please try again later."
        case .edgeFunctionError:
            return "The external service failed. Please try again."
        case .network:
            return
                "Unable to connect. Please check your connection and try again."
        case .unknown(_, let message): return message
        }
    }
}
