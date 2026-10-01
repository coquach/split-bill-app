//
//  HomeViewModelTests.swift
//  HomeTests
//

import Domains
import Foundation
@testable import Home
import Testing

@Suite("HomeViewModel")
@MainActor
struct HomeViewModelTests {
    private let profileRepository = MockProfileRepository()
    private let walletRepository = MockWalletRepository()
    private let transferRepository = MockTransferRepository()

    private func makeViewModel() -> HomeViewModel {
        HomeViewModel(
            profileRepository: profileRepository,
            walletRepository: walletRepository,
            transferRepository: transferRepository
        )
    }

    @Test
    func loadFetchesProfileWalletAndTheFirstTenTransfers() async {
        profileRepository.profile = makeProfile()
        walletRepository.wallet = makeWallet()
        transferRepository.transfers = [makeHistory()]
        let viewModel = makeViewModel()

        await viewModel.load()

        #expect(profileRepository.getCurrentProfileCalls == 1)
        #expect(walletRepository.getDefaultWalletCalls == 1)
        #expect(transferRepository.getTransfersCalls == 1)
        #expect(transferRepository.lastPage == 1)
        #expect(transferRepository.lastPageSize == 10)
        #expect(transferRepository.lastFilter == .all)
        #expect(viewModel.errorMessage == nil)
    }

    @Test
    func recentTransfersKeepOnlyTheFirstThree() async {
        profileRepository.profile = makeProfile()
        walletRepository.wallet = makeWallet()
        transferRepository.transfers = (1 ... 6).map { _ in makeHistory() }
        let viewModel = makeViewModel()

        await viewModel.load()

        #expect(viewModel.recentTransfers.count == 3)
        #expect(viewModel.recentTransfers[0].id == transferRepository.transfers[0].id)
        #expect(viewModel.recentTransfers[2].id == transferRepository.transfers[2].id)
    }

    @Test
    func aFailureSurfacesTheMessageAndKeepsTheViewModelEmpty() async {
        profileRepository.error = DomainError.unauthorized
        let viewModel = makeViewModel()

        await viewModel.load()

        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.profile == nil)
        #expect(viewModel.wallet == nil)
        #expect(viewModel.recentTransfers == [])

        viewModel.clearError()
        #expect(viewModel.errorMessage == nil)
    }

    @Test
    func aSecondLoadWhileInFlightIsANoop() async throws {
        profileRepository.profile = makeProfile()
        walletRepository.wallet = makeWallet()
        profileRepository.holdGetCurrentProfile = true
        let viewModel = makeViewModel()

        async let first = viewModel.load()
        // Let the first load enter the loading state before the second.
        try await Task.sleep(for: .milliseconds(100))
        await viewModel.load()

        profileRepository.resumeGetCurrentProfile()
        await first

        #expect(profileRepository.getCurrentProfileCalls == 1)
    }

    // MARK: - Display fallbacks

    @Test
    func displayNameGreetsTheProfileName() async {
        let viewModel = makeViewModel()
        // A missing profile still greets — with the "unknown" placeholder.
        #expect(viewModel.displayName == "Hi, unknown")

        profileRepository.profile = makeProfile(fullName: "  Binh Tran  ")
        walletRepository.wallet = makeWallet()
        await viewModel.load()
        #expect(viewModel.displayName == "Hi, Binh Tran")

        profileRepository.profile = makeProfile(fullName: "   ")
        await viewModel.load()
        #expect(viewModel.displayName == "Hi")
    }

    @Test
    func walletPresentationFallsBackWhenTheWalletIsMissing() {
        let viewModel = makeViewModel()

        #expect(viewModel.walletHolderName == "")
        #expect(viewModel.currency == "VND")
        #expect(viewModel.formattedBalance == "0")
        #expect(viewModel.lastFourWalletDigits == "••••")
    }

    @Test
    func walletPresentationRendersTheLoadedWallet() async {
        walletRepository.wallet = makeWallet(balance: 1_250_000)
        profileRepository.profile = makeProfile()
        let viewModel = makeViewModel()

        await viewModel.load()

        #expect(viewModel.walletHolderName == "Binh Tran")
        #expect(viewModel.currency == "VND")
        // The formatter pins "," as its grouping separator, so the output
        // is deterministic regardless of the host locale.
        #expect(viewModel.formattedBalance == "1,250,000")
        #expect(viewModel.lastFourWalletDigits == "3210")
    }
}
