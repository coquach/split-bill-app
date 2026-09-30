//
//  DomainErrorTests.swift
//  DomainsTests
//

import Domains
import Testing

@Suite("DomainError")
struct DomainErrorTests {
    private static let allCases: [DomainError] = [
        .validation, .unauthorized, .forbidden, .notFound, .duplicateResource,
        .invalidSourceTransfer, .pinNotSet, .invalidPinFormat, .invalidPin,
        .pinLocked, .invalidParticipantCount, .splitBillLocked,
        .splitBillNotCollectable, .noRemainingRepaymentSlot,
        .invalidRepaymentAmount, .lockedAmountMismatch, .insufficientBalance,
        .idempotencyKeyConflict, .rateLimitExceeded, .edgeFunctionError,
        .network, .unknown(code: "X", message: "boom")
    ]

    /// These strings are what the UI shows the user — none of them may be
    /// silently emptied by a refactor.
    @Test(arguments: allCases)
    func everyCaseHasAUserFacingMessage(error: DomainError) {
        #expect(!error.message.isEmpty)
    }

    /// `LocalizedError.errorDescription` mirrors `message`, so a thrown
    /// DomainError renders the user-facing string through `localizedDescription`
    /// instead of Swift's generic "The operation couldn't be completed" wrapper.
    @Test(arguments: allCases)
    func localizedDescriptionShowsTheUserFacingMessage(error: DomainError) {
        #expect(error.errorDescription == error.message)
        #expect(error.localizedDescription == error.message)
    }

    @Test
    func unknownEchoesItsMessage() {
        #expect(DomainError.unknown(code: "23505", message: "boom").message == "boom")
    }
}

@Suite("AuthError")
struct AuthErrorTests {
    private static let allCases: [AuthError] = [
        .invalidCredentials, .emailAlreadyRegistered, .emailNotConfirmed,
        .invalidEmail, .weakPassword, .rateLimited, .signUpDisabled,
        .network, .sessionExpired, .unknown
    ]

    @Test(arguments: allCases)
    func everyCaseHasAUserFacingMessage(error: AuthError) {
        #expect(!error.message.isEmpty)
    }
}
