//
//  ScanRepayViewModelTests.swift
//  SplitBillTests
//

import Domains
import Foundation
@testable import SplitBill
import Testing

@Suite("ScanRepayViewModel")
@MainActor
struct ScanRepayViewModelTests {
    private let repository = MockSplitQRRepository()

    private func makeViewModel() -> ScanRepayViewModel {
        ScanRepayViewModel(splitQRRepository: repository)
    }

    @Test
    func theViewModelStartsScanning() {
        #expect(makeViewModel().state == .scanning)
        #expect(makeViewModel().errorMessage == nil)
    }

    @Test
    func aDecodedQRPairsThePayloadWithItsReview() async {
        let review = makeReview()
        repository.review = review
        let viewModel = makeViewModel()

        let scanned = await viewModel.decode("qr-payload-1")

        #expect(repository.lastDecodedPayload == "qr-payload-1")
        #expect(scanned == ScannedRepayment(payload: "qr-payload-1", review: review))
        // Back to scanning so the camera can take the next code.
        #expect(viewModel.state == .scanning)
    }

    @Test
    func aDomainErrorFailsWithoutAReview() async {
        repository.error = DomainError.notFound
        let viewModel = makeViewModel()

        let scanned = await viewModel.decode("expired-payload")

        #expect(scanned == nil)
        #expect(viewModel.state == .failed(.notFound))
        #expect(viewModel.errorMessage == "The requested resource was not found.")
    }

    @Test
    func aSurpriseErrorIsWrappedAsUnknown() async {
        struct SurprisingError: Error {}
        repository.error = SurprisingError()
        let viewModel = makeViewModel()

        let scanned = await viewModel.decode("weird-payload")

        #expect(scanned == nil)
        guard case let .failed(.unknown(_, message)) = viewModel.state else {
            Issue.record("expected .failed(.unknown), got \(viewModel.state)")
            return
        }
        #expect(!message.isEmpty)
    }

    @Test
    func retryReturnsToScanning() async {
        repository.error = DomainError.notFound
        let viewModel = makeViewModel()
        _ = await viewModel.decode("expired-payload")
        #expect(viewModel.state == .failed(.notFound))

        viewModel.retry()

        #expect(viewModel.state == .scanning)
        #expect(viewModel.errorMessage == nil)
    }
}
