//
//  TransferFlowViewModelTests.swift
//  TransferTests
//

import Domains
import Foundation
import Testing
@testable import Transfer

@Suite("TransferFlowViewModel")
@MainActor
struct TransferFlowViewModelTests {
    private let walletRepository = MockWalletRepository()
    private let transferRepository = MockTransferRepository()

    private func makeViewModel(availableBalance: Amount? = Amount(1_000_000)) -> TransferFlowViewModel {
        let sessionStore = SessionStore(
            walletRepository: walletRepository,
            availableBalance: availableBalance
        )
        return TransferFlowViewModel(
            walletRepository: walletRepository,
            sessionStore: sessionStore,
            transferRepository: transferRepository
        )
    }

    /// Waits out the lookup debounce, then a little more for the RPC.
    private func waitOutDebounce() async throws {
        try await Task.sleep(
            for: TransferFlowViewModel.accountLookupDebounce + .milliseconds(300)
        )
    }

    // MARK: - Amount parsing

    @Test
    func amountParsesTheAmountText() {
        let viewModel = makeViewModel()
        viewModel.amountText = "250000"
        #expect(viewModel.amount == Amount(250_000))
    }

    @Test
    func garbageAmountTextParsesToZero() {
        let viewModel = makeViewModel()
        viewModel.amountText = "not a number"
        #expect(viewModel.amount == Amount(0))
    }

    // MARK: - Balance guard

    @Test
    func anUnknownBalanceNeverBlocksTheTransfer() {
        let viewModel = makeViewModel(availableBalance: nil)
        viewModel.amountText = "5000000"
        // Never flagged as overdrawing on an unknown balance — the server
        // re-checks at submit time and is the authority.
        #expect(viewModel.exceedsAvailableBalance == false)
    }

    @Test
    func anAmountAboveTheKnownBalanceIsFlagged() {
        let viewModel = makeViewModel(availableBalance: Amount(100_000))
        viewModel.amountText = "500000"
        #expect(viewModel.exceedsAvailableBalance == true)
    }

    @Test
    func anAmountWithinTheKnownBalancePasses() {
        let viewModel = makeViewModel(availableBalance: Amount(1_000_000))
        viewModel.amountText = "500000"
        #expect(viewModel.exceedsAvailableBalance == false)
    }

    // MARK: - Form validity

    @Test
    func theFormIsOnlyValidWithAFoundRecipientAndAPositiveAmount() async throws {
        let viewModel = makeViewModel()
        #expect(viewModel.isFormValid == false)

        walletRepository.recipient = makeRecipient()
        viewModel.accountNumber = "9876543210"
        try await waitOutDebounce()
        #expect(viewModel.lookupState == .found(try #require(walletRepository.recipient)))
        // Still invalid: no amount yet.
        #expect(viewModel.isFormValid == false)

        viewModel.amountText = "500000"
        #expect(viewModel.isFormValid == true)
    }

    @Test
    func theFormIsInvalidWhenTheAmountExceedsTheBalance() async throws {
        let viewModel = makeViewModel(availableBalance: Amount(100_000))
        walletRepository.recipient = makeRecipient()
        viewModel.accountNumber = "9876543210"
        try await waitOutDebounce()
        viewModel.amountText = "500000"

        #expect(viewModel.isFormValid == false)
    }

    // MARK: - Account lookup debounce

    @Test
    func rapidTypingResolvesExactlyOnceWithTheFinalQuery() async throws {
        walletRepository.recipient = makeRecipient()
        let viewModel = makeViewModel()

        viewModel.accountNumber = "9"
        viewModel.accountNumber = "987654"
        viewModel.accountNumber = "9876543210"
        try await waitOutDebounce()

        #expect(walletRepository.resolveWalletCalls == 1)
        #expect(walletRepository.lastResolvedQuery == "9876543210")
        #expect(viewModel.lookupState == .found(try #require(walletRepository.recipient)))
    }

    @Test
    func theQueryIsUpperCasedAndTrimmed() async throws {
        walletRepository.recipient = makeRecipient()
        let viewModel = makeViewModel()

        viewModel.accountNumber = "  9876543210abc  "
        try await waitOutDebounce()

        #expect(walletRepository.lastResolvedQuery == "9876543210ABC")
    }

    @Test
    func clearingTheAccountNumberResetsTheLookup() async throws {
        walletRepository.recipient = makeRecipient()
        let viewModel = makeViewModel()

        viewModel.accountNumber = "9876543210"
        try await waitOutDebounce()
        #expect(viewModel.lookupState != .idle)

        viewModel.accountNumber = ""
        #expect(viewModel.lookupState == .idle)
    }

    @Test
    func aNotFoundLookupSurfacesNotFound() async throws {
        walletRepository.error = DomainError.notFound
        let viewModel = makeViewModel()

        viewModel.accountNumber = "0000000001"
        try await waitOutDebounce()

        #expect(viewModel.lookupState == .notFound)
    }

    @Test
    func anUnexpectedLookupFailureSurfacesAFailedMessage() async throws {
        walletRepository.error = URLError(.notConnectedToInternet)
        let viewModel = makeViewModel()

        viewModel.accountNumber = "9876543210"
        try await waitOutDebounce()

        #expect(viewModel.lookupState == .failed(
            "Couldn't look up this account. Check your connection and try again."
        ))
    }

    @Test
    func cancelPendingLookupStopsAStaleResolution() async throws {
        walletRepository.recipient = makeRecipient()
        let viewModel = makeViewModel()

        viewModel.accountNumber = "9876543210"
        viewModel.cancelPendingLookup()
        try await waitOutDebounce()

        #expect(walletRepository.resolveWalletCalls == 0)
        #expect(viewModel.lookupState == .loading)
    }

    // MARK: - Confirm step

    @Test
    func confirmInputBuildsTheDraftFromTheResolvedRecipient() async throws {
        let recipient = makeRecipient()
        walletRepository.recipient = recipient
        let viewModel = makeViewModel()
        viewModel.accountNumber = "9876543210"
        viewModel.amountText = "500000"
        viewModel.descriptionText = "  Lunch  "
        try await waitOutDebounce()

        let confirmed = viewModel.confirmInput()

        #expect(confirmed == true)
        #expect(viewModel.draft?.receiverWalletId == recipient.walletId)
        #expect(viewModel.draft?.receiverAccountNumber == recipient.walletNumber)
        #expect(viewModel.draft?.receiverHolderName == recipient.holderName)
        #expect(viewModel.draft?.amount == Amount(500_000))
        #expect(viewModel.draft?.description == "Lunch")
    }

    @Test
    func confirmInputWithoutAFoundRecipientFails() {
        let viewModel = makeViewModel()
        viewModel.amountText = "500000"

        #expect(viewModel.confirmInput() == false)
        #expect(viewModel.draft == nil)
    }

    @Test
    func theAccountNumberIsMaskedToItsLastFourDigits() async throws {
        walletRepository.recipient = makeRecipient()
        let viewModel = makeViewModel()
        viewModel.accountNumber = "9876543210"
        try await waitOutDebounce()
        viewModel.confirmInput()

        #expect(viewModel.maskedAccountNumber == "•••• 3210")
    }

    // MARK: - OTP step

    //
    // Covered in TransferFlowOTPStepTests below, which shares the same
    // setup but lives in its own suite to keep each type body small.

    // Not tested: the idempotency key rotating on PIN-type failures — the
    // key is private and there is no seam to observe it without changing
    // behaviour.
}

@Suite("TransferFlowViewModel · OTP step")
@MainActor
struct TransferFlowOTPStepTests {
    private let walletRepository = MockWalletRepository()
    private let transferRepository = MockTransferRepository()

    private func makeViewModel(availableBalance: Amount? = Amount(1_000_000)) -> TransferFlowViewModel {
        let sessionStore = SessionStore(
            walletRepository: walletRepository,
            availableBalance: availableBalance
        )
        return TransferFlowViewModel(
            walletRepository: walletRepository,
            sessionStore: sessionStore,
            transferRepository: transferRepository
        )
    }

    /// Waits out the lookup debounce, then a little more for the RPC.
    private func waitOutDebounce() async throws {
        try await Task.sleep(
            for: TransferFlowViewModel.accountLookupDebounce + .milliseconds(300)
        )
    }

    @Test
    func isPinCompleteNeedsSixDigits() {
        let viewModel = makeViewModel()
        viewModel.pin = "12345"
        #expect(viewModel.isPinComplete == false)
        viewModel.pin = TransferPIN.testValue
        #expect(viewModel.isPinComplete == true)
    }

    @Test
    func anIncompletePinNeverReachesTheRepository() async {
        let viewModel = makeViewModel()
        viewModel.confirmInput()
        viewModel.pin = "123"

        await viewModel.submitOTP()

        #expect(transferRepository.createTransferCalls == 0)
        #expect(viewModel.state == .idle)
    }

    @Test
    func aSuccessfulSubmissionBuildsTheReceiptAndResetsTheState() async throws {
        let recipient = makeRecipient()
        walletRepository.recipient = recipient
        transferRepository.transfer = makeTransaction()
        let viewModel = makeViewModel()
        viewModel.accountNumber = "9876543210"
        viewModel.amountText = "500000"
        viewModel.descriptionText = "Lunch"
        try await waitOutDebounce()
        viewModel.confirmInput()
        viewModel.pin = TransferPIN.testValue

        await viewModel.submitOTP()

        #expect(viewModel.state == .idle)
        #expect(viewModel.receipt != nil)
        #expect(viewModel.receipt?.amount == Amount(500_000))
        #expect(viewModel.receipt?.receiverHolderName == recipient.holderName)
        #expect(transferRepository.lastCreateCommand?.pin == TransferPIN.testValue)
        #expect(transferRepository.lastCreateCommand?.recipientWalletId == recipient.walletId)
    }

    @Test
    func anEmptyDescriptionIsSentAsNil() async throws {
        walletRepository.recipient = makeRecipient()
        transferRepository.transfer = makeTransaction()
        let viewModel = makeViewModel()
        viewModel.accountNumber = "9876543210"
        viewModel.amountText = "500000"
        try await waitOutDebounce()
        viewModel.confirmInput()
        viewModel.pin = TransferPIN.testValue

        await viewModel.submitOTP()

        #expect(transferRepository.lastCreateCommand?.description == nil)
    }

    @Test
    func anInvalidPinSurfacesTheFailure() async throws {
        walletRepository.recipient = makeRecipient()
        transferRepository.error = DomainError.invalidPin
        let viewModel = makeViewModel()
        viewModel.accountNumber = "9876543210"
        viewModel.amountText = "500000"
        try await waitOutDebounce()
        viewModel.confirmInput()
        viewModel.pin = TransferPIN.testValue

        await viewModel.submitOTP()

        #expect(viewModel.state == .failed(.invalidPin))
        #expect(viewModel.errorMessage == "The transaction PIN is incorrect.")
        #expect(viewModel.receipt == nil)
    }

    @Test
    func aSurpriseErrorIsWrappedAsUnknown() async throws {
        walletRepository.recipient = makeRecipient()
        struct SurprisingError: Error {}
        transferRepository.error = SurprisingError()
        let viewModel = makeViewModel()
        viewModel.accountNumber = "9876543210"
        viewModel.amountText = "500000"
        try await waitOutDebounce()
        viewModel.confirmInput()
        viewModel.pin = TransferPIN.testValue

        await viewModel.submitOTP()

        #expect(viewModel.state != .idle)
        guard case let .failed(.unknown(_, message)) = viewModel.state else {
            Issue.record("expected .failed(.unknown), got \(viewModel.state)")
            return
        }
        #expect(!message.isEmpty)
    }

    @Test
    func retryClearsThePinAndTheFailure() async throws {
        walletRepository.recipient = makeRecipient()
        transferRepository.error = DomainError.invalidPin
        let viewModel = makeViewModel()
        viewModel.accountNumber = "9876543210"
        viewModel.amountText = "500000"
        try await waitOutDebounce()
        viewModel.confirmInput()
        viewModel.pin = TransferPIN.testValue
        await viewModel.submitOTP()
        #expect(viewModel.state == .failed(.invalidPin))

        viewModel.retry()

        #expect(viewModel.pin == "")
        #expect(viewModel.state == .idle)
    }
}
