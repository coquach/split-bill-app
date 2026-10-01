//
//  RepositoryErrorMapper.swift
//  Domains
//
//  Created by Co Quach on 27/9/26.
//

import Domains
import Foundation
import Supabase

enum RepositoryErrorMapper {
    static func map(_ error: Error) -> DomainError {
        if let domainError = error as? DomainError {
            return domainError
        }

        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost, .timedOut,
                .cannotConnectToHost, .cannotFindHost, .dnsLookupFailed:
                return .network
            default:
                return .unknown(
                    code: "\(urlError.code.rawValue)",
                    message: urlError.localizedDescription
                )
            }
        }

        if let postgrestError = error as? PostgrestError {
            return mapPostgrest(
                code: postgrestError.code,
                message: postgrestError.message
            )
        }

        // RestErrorBody is PostgrestError's raw-HTTP equivalent, for SupabaseRestClient callers.
        if let restError = error as? RestErrorBody {
            return mapPostgrest(
                code: restError.code,
                message: restError.message
            )
        }

        return .unknown(
            code: nil,
            message: error.localizedDescription
        )
    }

    static func mapPostgrest(code: String?, message: String) -> DomainError {
        let normalized = message.uppercased()

        if normalized.contains("VALIDATION_ERROR") {
            return .validation
        }
        if normalized.contains("UNAUTHORIZED") {
            return .unauthorized
        }
        if normalized.contains("FORBIDDEN") {
            return .forbidden
        }
        if normalized.contains("NOT_FOUND") || code == "PGRST116" {
            return .notFound
        }
        if normalized.contains("DUPLICATE_RESOURCE") || code == "23505" {
            return .duplicateResource
        }
        if normalized.contains("INVALID_SOURCE_TRANSFER") {
            return .invalidSourceTransfer
        }
        if normalized.contains("PIN_NOT_SET") {
            return .pinNotSet
        }
        if normalized.contains("INVALID_PIN_FORMAT") {
            return .invalidPinFormat
        }
        if normalized.contains("INVALID_PIN") {
            return .invalidPin
        }
        if normalized.contains("PIN_LOCKED") {
            return .pinLocked
        }
        if normalized.contains("INVALID_PARTICIPANT_COUNT") {
            return .invalidParticipantCount
        }
        if normalized.contains("SPLIT_BILL_LOCKED") {
            return .splitBillLocked
        }
        if normalized.contains("SPLIT_BILL_NOT_COLLECTABLE") {
            return .splitBillNotCollectable
        }
        if normalized.contains("NO_REMAINING_REPAYMENT_SLOT") {
            return .noRemainingRepaymentSlot
        }
        if normalized.contains("INVALID_REPAYMENT_AMOUNT") {
            return .invalidRepaymentAmount
        }
        if normalized.contains("LOCKED_AMOUNT_MISMATCH") {
            return .lockedAmountMismatch
        }
        if normalized.contains("INSUFFICIENT_BALANCE") {
            return .insufficientBalance
        }
        if normalized.contains("IDEMPOTENCY_KEY_CONFLICT") {
            return .idempotencyKeyConflict
        }
        if normalized.contains("RATE_LIMIT_EXCEEDED") {
            return .rateLimitExceeded
        }
        if normalized.contains("EDGE_FUNCTION_ERROR") {
            return .edgeFunctionError
        }

        return .unknown(code: code, message: message)
    }
}
