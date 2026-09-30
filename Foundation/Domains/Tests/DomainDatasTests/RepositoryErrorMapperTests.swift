//
//  RepositoryErrorMapperTests.swift
//  DomainDatasTests
//

import Domains
import Foundation
import Testing

@testable import DomainDatas

@Suite("RepositoryErrorMapper.mapPostgrest")
struct RepositoryErrorMapperPostgrestTests {

    struct Case: Sendable {
        let code: String?
        let message: String
        let expected: DomainError

        init(code: String? = nil, message: String, expected: DomainError) {
            self.code = code
            self.message = message
            self.expected = expected
        }
    }

    // One branch per keyword the mapper matches on. Message casing is
    // deliberately mixed — the mapper uppercases before matching.
    private static let cases: [Case] = [
        Case(message: "VALIDATION_ERROR: bad input", expected: .validation),
        Case(message: "validation_error: bad input", expected: .validation),
        Case(message: "UNAUTHORIZED: token expired", expected: .unauthorized),
        Case(message: "FORBIDDEN: not yours", expected: .forbidden),
        Case(message: "NOT_FOUND: no row", expected: .notFound),
        Case(code: "PGRST116", message: "JSON object requested", expected: .notFound),
        Case(message: "DUPLICATE_RESOURCE", expected: .duplicateResource),
        Case(code: "23505", message: "duplicate key value", expected: .duplicateResource),
        Case(message: "INVALID_SOURCE_TRANSFER", expected: .invalidSourceTransfer),
        Case(message: "PIN_NOT_SET", expected: .pinNotSet),
        Case(message: "INVALID_PIN_FORMAT", expected: .invalidPinFormat),
        Case(message: "INVALID_PIN", expected: .invalidPin),
        Case(message: "PIN_LOCKED", expected: .pinLocked),
        Case(message: "INVALID_PARTICIPANT_COUNT", expected: .invalidParticipantCount),
        Case(message: "SPLIT_BILL_LOCKED", expected: .splitBillLocked),
        Case(message: "SPLIT_BILL_NOT_COLLECTABLE", expected: .splitBillNotCollectable),
        Case(message: "NO_REMAINING_REPAYMENT_SLOT", expected: .noRemainingRepaymentSlot),
        Case(message: "INVALID_REPAYMENT_AMOUNT", expected: .invalidRepaymentAmount),
        Case(message: "LOCKED_AMOUNT_MISMATCH", expected: .lockedAmountMismatch),
        Case(message: "INSUFFICIENT_BALANCE", expected: .insufficientBalance),
        Case(message: "IDEMPOTENCY_KEY_CONFLICT", expected: .idempotencyKeyConflict),
        Case(message: "RATE_LIMIT_EXCEEDED", expected: .rateLimitExceeded),
        Case(message: "EDGE_FUNCTION_ERROR", expected: .edgeFunctionError),
    ]

    @Test(arguments: cases)
    func mapsKnownMessagesToTheirDomainError(case: Case) {
        #expect(
            RepositoryErrorMapper.mapPostgrest(code: `case`.code, message: `case`.message)
                == `case`.expected
        )
    }

    @Test
    func fallsBackToUnknownForAnUnmatchedMessage() {
        let mapped = RepositoryErrorMapper.mapPostgrest(
            code: "PGRST999",
            message: "something completely unexpected"
        )
        #expect(mapped == .unknown(code: "PGRST999", message: "something completely unexpected"))
    }

    @Test
    func unknownKeepsTheOriginalCasingOfTheMessage() {
        let mapped = RepositoryErrorMapper.mapPostgrest(code: nil, message: "Mixed Case Failure")
        #expect(mapped.message == "Mixed Case Failure")
    }

    @Test
    func matchesOnSubstringNotExactMessage() {
        // Real PostgREST/edge-function messages embed the keyword inside a
        // longer sentence — the substring match is what keeps them mapped.
        #expect(
            RepositoryErrorMapper.mapPostgrest(
                code: nil, message: "Wallet create_transfer failed: INSUFFICIENT_BALANCE for wallet"
            ) == .insufficientBalance
        )
    }
}

@Suite("RepositoryErrorMapper.map")
struct RepositoryErrorMapperTests {

    @Test
    func passesADomainErrorThroughUnchanged() {
        let error = RepositoryErrorMapper.map(DomainError.insufficientBalance)
        #expect(error == .insufficientBalance)
    }

    @Test
    func mapsAURLErrorToNetwork() {
        #expect(RepositoryErrorMapper.map(URLError(.notConnectedToInternet)) == .network)
        #expect(RepositoryErrorMapper.map(URLError(.timedOut)) == .network)
    }

    @Test
    func mapsARestErrorBodyThroughThePostgrestBranches() {
        let body = RestErrorBody(
            message: "INSUFFICIENT_BALANCE", code: nil, details: nil, hint: nil
        )
        #expect(RepositoryErrorMapper.map(body) == .insufficientBalance)
    }

    @Test
    func mapsAnyOtherErrorToUnknownWithItsDescription() {
        // NSError with an explicit description so the expected message is
        // deterministic — a bare Swift struct error gets the generic
        // "The operation couldn't be completed..." wrapper.
        let error = NSError(
            domain: "test",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "boom"]
        )
        #expect(RepositoryErrorMapper.map(error) == .unknown(code: nil, message: "boom"))
    }
}
