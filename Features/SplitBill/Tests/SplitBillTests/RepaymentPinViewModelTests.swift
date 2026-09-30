//
//  RepaymentPinViewModelTests.swift
//  SplitBillTests
//

import Domains
import Foundation
@testable import SplitBill
import Testing

@Suite("RepaymentPinViewModel")
@MainActor
struct RepaymentPinViewModelTests {
    private let repository = MockRepaymentRepository()
    private let scanned = ScannedRepayment(payload: "qr-payload-9", review: makeReview())

    private func makeViewModel() -> RepaymentPinViewModel {
        RepaymentPinViewModel(scanned: scanned, repaymentRepository: repository)
    }

    @Test
    func thePinIsCompleteOnlyAtSixDigits() {
        let viewModel = makeViewModel()

        viewModel.pin = "12345"
        #expect(viewModel.isPinComplete == false)

        viewModel.pin = "123456"
        #expect(viewModel.isPinComplete == true)

        viewModel.pin = "1234567"
        #expect(viewModel.isPinComplete == false)
    }

    @Test
    func anIncompletePinNeverReachesTheRepository() async {
        let viewModel = makeViewModel()
        viewModel.pin = "123"

        await viewModel.submit()

        #expect(repository.createQRRepaymentCalls == 0)
        #expect(viewModel.state == .idle)
        #expect(viewModel.receipt == nil)
    }

    @Test
    func aSuccessfulSubmitCarriesTheScannedPayloadAndReturnsTheReceipt() async {
        let receipt = makeReceipt()
        repository.receipt = receipt
        let viewModel = makeViewModel()
        viewModel.pin = "123456"

        await viewModel.submit()

        #expect(viewModel.state == .idle)
        #expect(viewModel.receipt == receipt)
        #expect(repository.lastCreateCommand?.qrPayload == "qr-payload-9")
        #expect(repository.lastCreateCommand?.pin == "123456")
        #expect(repository.lastCreateCommand?.note == nil)
        #expect(repository.lastCreateCommand?.idempotencyKey.isEmpty == false)
    }

    @Test
    func aSecondSubmitWhileInFlightIsANoop() async throws {
        repository.receipt = makeReceipt()
        repository.holdCreateRepayment = true
        let viewModel = makeViewModel()
        viewModel.pin = "123456"

        async let first = viewModel.submit()
        // Let the first call enter the submitting state before the second.
        try await Task.sleep(for: .milliseconds(100))
        await viewModel.submit()

        repository.resumeCreateRepayment()
        await first

        #expect(repository.createQRRepaymentCalls == 1)
    }

    @Test
    func anInvalidPinSurfacesTheFailure() async {
        repository.error = DomainError.invalidPin
        let viewModel = makeViewModel()
        viewModel.pin = "123456"

        await viewModel.submit()

        #expect(viewModel.state == .failed(.invalidPin))
        #expect(viewModel.receipt == nil)
    }

    @Test
    func aSurpriseErrorIsWrappedAsUnknown() async {
        struct SurprisingError: Error {}
        repository.error = SurprisingError()
        let viewModel = makeViewModel()
        viewModel.pin = "123456"

        await viewModel.submit()

        guard case let .failed(.unknown(_, message)) = viewModel.state else {
            Issue.record("expected .failed(.unknown), got \(viewModel.state)")
            return
        }
        #expect(!message.isEmpty)
    }

    @Test
    func retryClearsThePinAndTheFailure() async {
        repository.error = DomainError.invalidPin
        let viewModel = makeViewModel()
        viewModel.pin = "123456"
        await viewModel.submit()
        #expect(viewModel.state == .failed(.invalidPin))

        viewModel.retry()

        #expect(viewModel.pin == "")
        #expect(viewModel.state == .idle)
    }

    // Not tested: the idempotency key rotating on PIN-type failures — the
    // key is private and there is no seam to observe it without changing
    // behaviour (same gap as TransferFlowViewModel).
}
