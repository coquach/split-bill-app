//
//  TransactionHistoryViewModelTests.swift
//  TransferTests
//

import Domains
import Foundation
import Testing
@testable import Transfer

@Suite("TransactionHistoryViewModel")
@MainActor
struct TransactionHistoryViewModelTests {
    private let repository = MockTransferRepository()

    /// A fixed calendar pinned to a timezone far from midnight so "now"
    /// inside the test never straddles a day boundary while it runs.
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Ho_Chi_Minh")!
        return calendar
    }

    private func makeViewModel() -> TransactionHistoryViewModel {
        TransactionHistoryViewModel(
            transferRepository: repository,
            calendar: calendar
        )
    }

    private func day(_ daysFromToday: Int, hour: Int) -> Date {
        calendar.date(
            byAdding: .day,
            value: daysFromToday,
            to: calendar.startOfDay(for: Date().addingTimeInterval(3600))
        )!.addingTimeInterval(TimeInterval(hour * 3600))
    }

    @Test
    func loadFetchesTheFirstPageWithTheCurrentFilter() async {
        let viewModel = makeViewModel()

        await viewModel.load()

        #expect(repository.getTransfersCalls == 1)
        #expect(repository.lastFilter == .all)
        guard case .loaded = viewModel.state else {
            Issue.record("expected .loaded, got \(viewModel.state)")
            return
        }
    }

    @Test
    func itemsOnTheSameDayShareOneSectionInServerOrder() async {
        let noon = day(0, hour: 12)
        let evening = day(0, hour: 19)
        repository.transfers = [
            makeHistory(createdAt: noon),
            makeHistory(createdAt: evening)
        ]
        let viewModel = makeViewModel()

        await viewModel.load()

        guard case let .loaded(sections) = viewModel.state else {
            Issue.record("expected .loaded, got \(viewModel.state)")
            return
        }
        #expect(sections.count == 1)
        #expect(sections[0].title == "Today")
        #expect(sections[0].items.count == 2)
        #expect(sections[0].items[0].createdAt == noon)
        #expect(sections[0].items[1].createdAt == evening)
    }

    @Test
    func yesterdayAndOlderDaysGetTheirOwnSectionsNewestFirst() async {
        let today = day(0, hour: 10)
        let yesterday = day(-1, hour: 10)
        let twoDaysAgo = day(-2, hour: 10)
        repository.transfers = [
            makeHistory(createdAt: today),
            makeHistory(createdAt: yesterday),
            makeHistory(createdAt: twoDaysAgo)
        ]
        let viewModel = makeViewModel()

        await viewModel.load()

        guard case let .loaded(sections) = viewModel.state else {
            Issue.record("expected .loaded, got \(viewModel.state)")
            return
        }
        #expect(sections.count == 3)
        #expect(sections[0].title == "Today")
        #expect(sections[1].title == "Yesterday")
        // Older days render via the day formatter — assert it isn't one of
        // the relative labels rather than pinning a locale string.
        #expect(sections[2].title != "Today")
        #expect(sections[2].title != "Yesterday")
        #expect(!sections[2].title.isEmpty)
    }

    @Test
    func aRepositoryFailureSurfacesTheDomainError() async {
        repository.error = DomainError.notFound
        let viewModel = makeViewModel()

        await viewModel.load()

        #expect(viewModel.state == .failed(.notFound))
        #expect(viewModel.errorMessage == "The requested resource was not found.")
    }

    @Test
    func selectingANewFilterRefetchesWithIt() async {
        let viewModel = makeViewModel()
        await viewModel.load()
        #expect(repository.lastFilter == .all)

        await viewModel.selectFilter(.transfer)

        #expect(repository.getTransfersCalls == 2)
        #expect(viewModel.selectedFilter == .transfer)
        #expect(repository.lastFilter == .transfer)
    }

    @Test
    func selectingTheCurrentFilterIsANoop() async {
        let viewModel = makeViewModel()
        await viewModel.load()

        await viewModel.selectFilter(.all)

        #expect(repository.getTransfersCalls == 1)
    }

    @Test
    func filterLabelsCoverAllThreeCases() {
        let viewModel = makeViewModel()
        #expect(viewModel.label(for: .all) == "All")
        #expect(viewModel.label(for: .transfer) == "Transfer")
        #expect(viewModel.label(for: .repayment) == "Repayment")
    }

    @Test
    func rowTitlePrefersTheNameThenTheWalletNumber() {
        let viewModel = makeViewModel()
        #expect(
            viewModel.title(for: makeHistory(counterpartyName: "Binh Tran", counterpartyWalletNumber: "123"))
                == "Binh Tran"
        )
        #expect(
            viewModel.title(for: makeHistory(counterpartyName: nil, counterpartyWalletNumber: "9876543210"))
                == "9876543210"
        )
        #expect(
            viewModel.title(for: makeHistory(counterpartyName: nil, counterpartyWalletNumber: nil))
                == "Unknown"
        )
    }

    @Test
    func rowSubtitleNamesTheKindAndTheTime() {
        let viewModel = makeViewModel()
        let repayment = viewModel.subtitle(for: makeHistory(isRepayment: true))
        let transfer = viewModel.subtitle(for: makeHistory(isRepayment: false))

        #expect(repayment.hasPrefix("Split payment · "))
        #expect(transfer.hasPrefix("Transfer · "))
    }

    @Test
    func amountTextPrefixesTheDirectionSignAndAlwaysSaysVND() {
        let viewModel = makeViewModel()
        let incoming = viewModel.amountText(for: makeHistory(direction: .received, amount: 200_000))
        let outgoing = viewModel.amountText(for: makeHistory(direction: .sent, amount: 200_000))

        #expect(incoming.hasPrefix("+"))
        #expect(outgoing.hasPrefix("-"))
        #expect(incoming.hasSuffix("VND"))
        #expect(outgoing.hasSuffix("VND"))
        #expect(viewModel.isIncoming(makeHistory(direction: .received)) == true)
        #expect(viewModel.isIncoming(makeHistory(direction: .sent)) == false)
    }
}
