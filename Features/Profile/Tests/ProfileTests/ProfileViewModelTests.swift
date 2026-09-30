//
//  ProfileViewModelTests.swift
//  ProfileTests
//

import Domains
import Foundation
@testable import Profile
import Testing

@Suite("ProfileViewModel")
@MainActor
struct ProfileViewModelTests {
    private let profileRepository = MockProfileRepository()
    private let pinRepository = MockPinRepository()
    private let authRepository = MockAuthRepository()

    private func makeViewModel() -> ProfileViewModel {
        ProfileViewModel(
            profileRepository: profileRepository,
            pinRepository: pinRepository,
            authRepository: authRepository
        )
    }

    // MARK: - Load

    @Test
    func loadFetchesTheProfileAndThePinStatus() async {
        profileRepository.profile = makeProfile()
        pinRepository.hasPin = true
        let viewModel = makeViewModel()

        await viewModel.load()

        #expect(profileRepository.getCurrentProfileCalls == 1)
        #expect(pinRepository.checkPinStatusCalls == 1)
        #expect(viewModel.hasPin == true)
        #expect(viewModel.errorMessage == nil)
    }

    @Test
    func aFailureSurfacesTheMessageAndClearsOnDemand() async {
        profileRepository.error = DomainError.unauthorized
        let viewModel = makeViewModel()

        await viewModel.load()

        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.profile == nil)

        viewModel.clearError()
        #expect(viewModel.errorMessage == nil)
    }

    @Test
    func aSecondLoadWhileLoadingIsANoop() async throws {
        profileRepository.profile = makeProfile()
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
    func displayFieldsFallBackUntilTheProfileLoads() {
        let viewModel = makeViewModel()

        #expect(viewModel.displayName == "Your profile")
        #expect(viewModel.email == "Not provided")
        #expect(viewModel.phoneNumber == "Not provided")
        #expect(viewModel.statusText == "Account")
    }

    @Test
    func displayFieldsRenderTheLoadedProfile() async {
        profileRepository.profile = makeProfile(
            fullName: "  Binh Tran  ",
            email: "binh@example.com",
            phoneNumber: "0912345678",
            status: .active
        )
        let viewModel = makeViewModel()

        await viewModel.load()

        #expect(viewModel.displayName == "Binh Tran")
        #expect(viewModel.email == "binh@example.com")
        #expect(viewModel.phoneNumber == "0912345678")
        #expect(viewModel.statusText == "Active")
    }

    @Test
    func aBlankNameFallsBackToThePlaceholder() async {
        profileRepository.profile = makeProfile(fullName: "   ")
        let viewModel = makeViewModel()

        await viewModel.load()

        #expect(viewModel.displayName == "Your profile")
    }

    // MARK: - PIN setup

    @Test
    func aSuccessfulSetupMarksThePinAsPresent() async {
        let viewModel = makeViewModel()

        let succeeded = await viewModel.setupPin("123456")

        #expect(succeeded == true)
        #expect(pinRepository.lastSetupPin == "123456")
        #expect(viewModel.hasPin == true)
        #expect(viewModel.isSettingUpPin == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test
    func aRejectedSetupSurfacesTheMessageAndKeepsNoPin() async {
        pinRepository.setupResult = false
        let viewModel = makeViewModel()

        let succeeded = await viewModel.setupPin("123456")

        #expect(succeeded == false)
        #expect(viewModel.hasPin == false)
        #expect(viewModel.errorMessage == "Unable to set up PIN.")
        #expect(viewModel.isSettingUpPin == false)
    }

    @Test
    func aThrownSetupSurfacesTheMessageAndKeepsNoPin() async {
        pinRepository.error = DomainError.invalidPinFormat
        let viewModel = makeViewModel()

        let succeeded = await viewModel.setupPin("12")

        #expect(succeeded == false)
        #expect(viewModel.hasPin == false)
        #expect(viewModel.errorMessage != nil)
    }

    @Test
    func aSetupWhileAlreadySettingUpIsRejected() async throws {
        pinRepository.holdSetupPin = true
        let viewModel = makeViewModel()

        async let first = viewModel.setupPin("123456")
        // Let the first call enter the setup state before the second.
        try await Task.sleep(for: .milliseconds(100))
        let second = await viewModel.setupPin("654321")

        pinRepository.resumeSetupPin()
        let firstResult = await first

        #expect(second == false)
        #expect(firstResult == true)
        #expect(pinRepository.setupPinCalls == 1)
        #expect(pinRepository.lastSetupPin == "123456")
    }

    // MARK: - PIN change

    @Test
    func aSuccessfulChangeMarksThePinAsPresent() async {
        let viewModel = makeViewModel()

        let succeeded = await viewModel.changePin(currentPin: "111111", newPin: "222222")

        #expect(succeeded == true)
        #expect(pinRepository.lastOldPin == "111111")
        #expect(pinRepository.lastNewPin == "222222")
        #expect(viewModel.hasPin == true)
        #expect(viewModel.errorMessage == nil)
    }

    @Test
    func aRejectedChangeSurfacesTheMessage() async {
        pinRepository.changeResult = false
        let viewModel = makeViewModel()

        let succeeded = await viewModel.changePin(currentPin: "111111", newPin: "222222")

        #expect(succeeded == false)
        #expect(viewModel.errorMessage == "Unable to change PIN.")
    }

    @Test
    func aThrownChangeSurfacesTheMessage() async {
        pinRepository.error = DomainError.invalidPin
        let viewModel = makeViewModel()

        let succeeded = await viewModel.changePin(currentPin: "111111", newPin: "222222")

        #expect(succeeded == false)
        #expect(viewModel.errorMessage != nil)
    }

    // MARK: - Sign out

    @Test
    func signOutReachesTheAuthRepository() async {
        let viewModel = makeViewModel()

        await viewModel.signOut()

        #expect(authRepository.signOutCalls == 1)
        #expect(viewModel.isSigningOut == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test
    func aFailedSignOutSurfacesTheMessage() async {
        struct SurprisingError: Error {}
        authRepository.signOutError = SurprisingError()
        let viewModel = makeViewModel()

        await viewModel.signOut()

        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isSigningOut == false)
    }

    @Test
    func aSecondSignOutWhileInFlightIsANoop() async throws {
        authRepository.holdSignOut = true
        let viewModel = makeViewModel()

        async let first = viewModel.signOut()
        // Let the first call enter the signing-out state before the second.
        try await Task.sleep(for: .milliseconds(100))
        await viewModel.signOut()

        authRepository.resumeSignOut()
        await first

        #expect(authRepository.signOutCalls == 1)
    }
}
