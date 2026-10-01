//
//  TransactionDetailViewModelTests.swift
//  TransferTests
//

import Domains
import Foundation
import Testing
@testable import Transfer

@Suite("TransactionDetailViewModel")
@MainActor
struct TransactionDetailViewModelTests {
    private let repository = MockTransferRepository()

    private func makeViewModel(isOutgoing: Bool = true) -> TransactionDetailViewModel {
        TransactionDetailViewModel(
            transactionId: UUID(),
            receiverHolderName: "Binh Tran",
            isOutgoing: isOutgoing,
            transferRepository: repository
        )
    }

    @Test
    func loadPutsTheDetailIntoTheLoadedState() async {
        let detail = makeDetail()
        repository.detail = detail
        let viewModel = makeViewModel()

        await viewModel.load()

        #expect(viewModel.state == .loaded(detail))
        #expect(viewModel.receiverHolderName == "Binh Tran")
    }

    @Test
    func aDomainErrorIsSurfacedAsIs() async {
        repository.error = DomainError.notFound
        let viewModel = makeViewModel()

        await viewModel.load()

        #expect(viewModel.state == .failed(.notFound))
    }

    @Test
    func aSurpriseErrorIsWrappedAsUnknown() async {
        struct SurprisingError: Error {}
        repository.error = SurprisingError()
        let viewModel = makeViewModel()

        await viewModel.load()

        guard case let .failed(.unknown(_, message)) = viewModel.state else {
            Issue.record("expected .failed(.unknown), got \(viewModel.state)")
            return
        }
        #expect(!message.isEmpty)
    }

    @Test
    func outgoingAmountCarriesAMinusAndVND() {
        let viewModel = makeViewModel(isOutgoing: true)
        let text = viewModel.formattedAmount(500_000)

        #expect(text.hasPrefix("-"))
        #expect(text.hasSuffix("VND"))
        #expect(text.contains("500"))
    }

    @Test
    func incomingAmountCarriesAPlusMatchingTheHistoryListSign() {
        let viewModel = makeViewModel(isOutgoing: false)
        let text = viewModel.formattedAmount(500_000)

        #expect(text.hasPrefix("+"))
        #expect(text.hasSuffix("VND"))
        #expect(text.contains("500"))
    }

    @Test
    func formattedDateJoinsTheDayAndTheTime() {
        let viewModel = makeViewModel()
        let date = Date(timeIntervalSince1970: 1_700_000_000)

        let text = viewModel.formattedDate(date)

        // Locale-dependent rendering — pin the structure, not the words.
        #expect(text.contains(" · "))
        #expect(!text.isEmpty)
    }
}
