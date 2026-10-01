//
//  SplitDetailsViewModelTests.swift
//  SplitBillTests
//

import Domains
import Foundation
@testable import SplitBill
import Testing

@Suite("SplitDetailsViewModel")
@MainActor
struct SplitDetailsViewModelTests {
    private let splitBillRepository = MockSplitBillRepository()
    private let repaymentRepository = MockRepaymentRepository()

    private func makeViewModel(splitBillId: UUID = UUID()) -> SplitDetailsViewModel {
        SplitDetailsViewModel(
            splitBillId: splitBillId,
            splitBillRepository: splitBillRepository,
            repaymentRepository: repaymentRepository
        )
    }

    /// A loaded state whose bill has `requiredSlots` open slots and whose
    /// repayment list carries one repayment per given status.
    private func makeLoaded(
        requiredSlots: Int,
        perPersonAmount: Amount = Amount(33.33),
        statuses: [RepaymentStatus]
    ) -> SplitDetailsViewModel.Loaded {
        let bill = makeSplitBill(
            participantCount: requiredSlots + 1,
            perPersonAmount: perPersonAmount
        )
        let repayments = statuses.map { status in
            makeRepayment(amount: Amount(33.33), status: status)
        }
        return SplitDetailsViewModel.Loaded(
            detail: makeDetail(splitBill: bill),
            paidRepayments: repayments.filter { $0.status == .success }
        )
    }

    // MARK: - Loading

    @Test
    func loadFetchesDetailAndRepaymentsForTheSameBill() async {
        let billId = UUID()
        splitBillRepository.detail = makeDetail(splitBill: makeSplitBill())
        repaymentRepository.repayments = [makeRepayment()]
        let viewModel = makeViewModel(splitBillId: billId)

        await viewModel.load()

        #expect(splitBillRepository.lastDetailId == billId)
        #expect(repaymentRepository.lastRepaymentsSplitBillId == billId)
        guard case let .loaded(loaded) = viewModel.state else {
            Issue.record("expected .loaded, got \(viewModel.state)")
            return
        }
        #expect(loaded.paidRepayments.count == 1)
        #expect(viewModel.errorMessage == nil)
    }

    @Test
    func failedAndRefundedRepaymentsNeverCountAsPaid() async {
        splitBillRepository.detail = makeDetail(splitBill: makeSplitBill())
        repaymentRepository.repayments = [
            makeRepayment(status: .success),
            makeRepayment(status: .failed),
            makeRepayment(status: .refunded)
        ]
        let viewModel = makeViewModel()

        await viewModel.load()

        guard case let .loaded(loaded) = viewModel.state else {
            Issue.record("expected .loaded, got \(viewModel.state)")
            return
        }
        #expect(loaded.paidRepayments.count == 1)
        #expect(loaded.paidRepayments.allSatisfy { $0.status == .success })
    }

    @Test
    func aRepositoryFailureSurfacesTheDomainError() async {
        splitBillRepository.error = DomainError.notFound
        let viewModel = makeViewModel()

        await viewModel.load()

        #expect(viewModel.state == .failed(.notFound))
        #expect(viewModel.errorMessage == "The requested resource was not found.")
    }

    @Test
    func aSurpriseErrorIsWrappedAsUnknown() async {
        struct SurprisingError: Error {}
        repaymentRepository.error = SurprisingError()
        splitBillRepository.detail = makeDetail(splitBill: makeSplitBill())
        let viewModel = makeViewModel()

        await viewModel.load()

        guard case let .failed(.unknown(_, message)) = viewModel.state else {
            Issue.record("expected .failed(.unknown), got \(viewModel.state)")
            return
        }
        #expect(!message.isEmpty)
    }

    // MARK: - Derived figures

    @Test
    func pendingCountSubtractsThePaidSlotsAndClampsAtZero() {
        let viewModel = makeViewModel()

        let pending = viewModel.pendingCount(makeLoaded(requiredSlots: 5, statuses: [.success, .success]))
        #expect(pending == 3)

        let overpaid = viewModel.pendingCount(makeLoaded(requiredSlots: 2, statuses: [.success, .success, .success]))
        #expect(overpaid == 0)
    }

    @Test
    func progressIsThePaidShareOfTheRequiredSlots() {
        let viewModel = makeViewModel()

        #expect(viewModel.progress(makeLoaded(requiredSlots: 5, statuses: [.success, .success])) == 0.4)
        #expect(viewModel.progress(makeLoaded(requiredSlots: 5, statuses: [])) == 0)
    }

    @Test
    func collectedSumsOnlyTheSuccessfulRepayments() {
        let viewModel = makeViewModel()

        let loaded = SplitDetailsViewModel.Loaded(
            detail: makeDetail(splitBill: makeSplitBill()),
            paidRepayments: [makeRepayment(amount: Amount(33.33)), makeRepayment(amount: Amount(16.67))]
        )

        #expect(viewModel.collected(loaded) == Amount(50))
    }

    @Test
    func remainingIsThePendingCountTimesThePerPersonAmount() {
        let viewModel = makeViewModel()

        let loaded = makeLoaded(requiredSlots: 4, perPersonAmount: Amount(25), statuses: [.success])

        #expect(viewModel.pendingCount(loaded) == 3)
        #expect(viewModel.remaining(loaded) == Amount(75))
    }

    @Test
    func statusTextCoversEverySplitBillStatus() {
        let viewModel = makeViewModel()

        #expect(viewModel.statusText(makeLoaded(requiredSlots: 2, statuses: [])) == "Active")

        let settled = viewModel.statusText(
            SplitDetailsViewModel.Loaded(
                detail: makeDetail(splitBill: makeSplitBill(status: .closed)),
                paidRepayments: []
            )
        )
        #expect(settled == "Settled")

        let expired = viewModel.statusText(
            SplitDetailsViewModel.Loaded(
                detail: makeDetail(splitBill: makeSplitBill(status: .expired)),
                paidRepayments: []
            )
        )
        #expect(expired == "Expired")

        let cancelled = viewModel.statusText(
            SplitDetailsViewModel.Loaded(
                detail: makeDetail(splitBill: makeSplitBill(status: .cancelled)),
                paidRepayments: []
            )
        )
        #expect(cancelled == "Cancelled")
    }

    // MARK: - Formatting

    @Test
    func paidAtTextIsNilWithoutAPaidAtDate() {
        let viewModel = makeViewModel()

        #expect(viewModel.paidAtText(makeRepayment(paidAt: nil)) == nil)
        #expect(viewModel.paidAtText(makeRepayment(paidAt: Date(timeIntervalSince1970: 1_700_000_000))) != nil)
    }

    @Test
    func moneyRendersTheAmountWithTheCurrency() {
        let viewModel = makeViewModel()

        let text = viewModel.money(Amount(33.33))

        #expect(text.hasSuffix(" VND"))
        #expect(text.contains("33.33") || text.contains("33,33"))
    }
}
