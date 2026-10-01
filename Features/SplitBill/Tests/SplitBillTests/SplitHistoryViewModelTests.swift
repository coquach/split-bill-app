//
//  SplitHistoryViewModelTests.swift
//  SplitBillTests
//

import Domains
import Foundation
@testable import SplitBill
import Testing

@Suite("SplitHistoryViewModel")
@MainActor
struct SplitHistoryViewModelTests {
    private let repository = MockSplitBillRepository()

    private func makeViewModel() -> SplitHistoryViewModel {
        SplitHistoryViewModel(splitBillRepository: repository)
    }

    @Test
    func loadFetchesBothRolesWithTheAllStatusFilter() async {
        repository.pageResult = SplitBillPage(items: [], totalCount: 0, page: 1, pageSize: 50)
        let viewModel = makeViewModel()

        await viewModel.load()

        // Created and transferred load in parallel — one call per role.
        #expect(repository.getSplitBillsCalls == 2)
        #expect(repository.rolesRequested == [.created, .repaid])
        #expect(repository.lastStatusFilter == .all)
        #expect(repository.lastPage == 1)
        #expect(repository.lastPageSize == 50)
    }

    @Test
    func eachRolePageLandsInItsOwnList() async {
        let createdBill = makeListItem(title: "Mine", status: .active)
        let transferredBill = makeListItem(title: "Theirs", status: .closed)
        repository.pageResultsByRole = [
            .created: SplitBillPage(items: [createdBill], totalCount: 1, page: 1, pageSize: 50),
            .repaid: SplitBillPage(items: [transferredBill], totalCount: 1, page: 1, pageSize: 50),
        ]
        let viewModel = makeViewModel()

        await viewModel.load()

        guard case let .loaded(created, transferred) = viewModel.state else {
            Issue.record("expected .loaded, got \(viewModel.state)")
            return
        }
        #expect(created == [createdBill])
        #expect(transferred == [transferredBill])
    }

    @Test
    func switchingFilterIsALocalPickWithoutARefetch() async {
        let active = makeListItem(title: "Active one", status: .active)
        let closed = makeListItem(title: "Closed one", status: .closed)
        repository.pageResult = SplitBillPage(items: [active, closed], totalCount: 2, page: 1, pageSize: 50)
        let viewModel = makeViewModel()
        await viewModel.load()

        // All is the default filter — everything the pages returned shows up.
        #expect(viewModel.visibleBills == [active, closed])

        viewModel.select(.closed)

        #expect(viewModel.selectedFilter == .closed)
        #expect(viewModel.visibleBills == [closed])
        #expect(repository.getSplitBillsCalls == 2)
    }

    @Test
    func statusFiltersPickExactStatuses() async {
        let active = makeListItem(title: "Active one", status: .active)
        let closed = makeListItem(title: "Closed one", status: .closed)
        let expired = makeListItem(title: "Expired one", status: .expired)
        let cancelled = makeListItem(title: "Cancelled one", status: .cancelled)
        repository.pageResult = SplitBillPage(
            items: [active, closed, expired, cancelled],
            totalCount: 4,
            page: 1,
            pageSize: 50
        )
        let viewModel = makeViewModel()
        await viewModel.load()

        // The declared filter has no cancelled case, so cancelled bills only
        // ever show up under All.
        viewModel.select(.active)
        #expect(viewModel.visibleBills == [active])

        viewModel.select(.closed)
        #expect(viewModel.visibleBills == [closed])

        viewModel.select(.expired)
        #expect(viewModel.visibleBills == [expired])

        viewModel.select(.all)
        #expect(viewModel.visibleBills == [active, closed, expired, cancelled])
    }

    @Test
    func chipLabelsMatchTheBadgeWording() {
        let viewModel = makeViewModel()

        #expect(viewModel.label(for: .all) == "All")
        #expect(viewModel.label(for: .active) == "Active")
        #expect(viewModel.label(for: .closed) == "Settled")
        #expect(viewModel.label(for: .expired) == "Expired")
    }

    @Test
    func visibleBillsIsEmptyUntilLoaded() {
        let viewModel = makeViewModel()

        #expect(viewModel.visibleBills == [])
    }

    @Test
    func aRepositoryFailureSurfacesTheDomainError() async {
        repository.error = DomainError.unauthorized
        let viewModel = makeViewModel()

        await viewModel.load()

        #expect(viewModel.state == .failed(.unauthorized))
        #expect(viewModel.errorMessage != nil)
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
    func subtitleReportsPaidAgainstRequired() {
        let viewModel = makeViewModel()

        #expect(viewModel.subtitle(for: makeListItem(requiredSlots: 5, paidSlots: 2)) == "2 of 5 paid")
        #expect(viewModel.subtitle(for: makeListItem(requiredSlots: 2, paidSlots: 2)) == "2 of 2 paid")
    }

    @Test
    func amountTextRendersTheListAmountWithTheCurrency() {
        let viewModel = makeViewModel()

        let text = viewModel.amountText(for: makeListItem(totalAmount: 200_000))

        #expect(text.hasSuffix(" VND"))
        // Rendered through Amount.formatted, so compare against the same
        // rendering instead of pinning a locale's separators.
        #expect(text == "\(Amount(200_000).formatted) VND")
    }

    @Test
    func statusTextCoversEveryStatus() {
        let viewModel = makeViewModel()

        #expect(viewModel.statusText(for: makeListItem(status: .active)) == "Active")
        #expect(viewModel.statusText(for: makeListItem(status: .closed)) == "Settled")
        #expect(viewModel.statusText(for: makeListItem(status: .expired)) == "Expired")
        #expect(viewModel.statusText(for: makeListItem(status: .cancelled)) == "Cancelled")
    }
}
