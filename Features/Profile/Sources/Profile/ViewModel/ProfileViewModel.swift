import Domains
import Foundation
import Observation

@MainActor
@Observable
public final class ProfileViewModel {
    private(set) var profile: Profile?
    private(set) var hasPin = false
    private(set) var isLoading = false
    private(set) var isSettingUpPin = false
    private(set) var isSigningOut = false
    private(set) var errorMessage: String?

    private let profileRepository: IProfileRepository
    private let pinRepository: IPinRepository
    private let authRepository: IAuthRepository

    public init(
        profileRepository: IProfileRepository,
        pinRepository: IPinRepository,
        authRepository: IAuthRepository
    ) {
        self.profileRepository = profileRepository
        self.pinRepository = pinRepository
        self.authRepository = authRepository
    }

    var displayName: String {
        let value =
            profile?.fullName?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return value.isEmpty ? "Your profile" : value
    }

    var email: String {
        profile?.email ?? "Not provided"
    }

    var phoneNumber: String {
        profile?.phoneNumber ?? "Not provided"
    }

    var statusText: String {
        switch profile?.status {
        case .active:
            return "Active"
        default:
            return "Account"
        }
    }

    func load() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            async let profileTask = profileRepository.getCurrentProfile()
            async let pinTask = pinRepository.checkPinStatus()

            let (loadedProfile, loadedHasPin) = try await (
                profileTask,
                pinTask
            )

            profile = loadedProfile
            hasPin = loadedHasPin
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func setupPin(_ pin: String) async -> Bool {
        guard !isSettingUpPin else {
            return false
        }

        isSettingUpPin = true
        errorMessage = nil

        defer {
            isSettingUpPin = false
        }

        do {
            let success = try await pinRepository.setupPin(pin)

            guard success else {
                errorMessage = "Unable to set up PIN."
                return false
            }

            hasPin = true
            return true

        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // Used by Change PIN to check the current PIN before the user types a new one.
    func verifyPin(_ pin: String) async -> Bool {
        do {
            return try await pinRepository.verifyPin(pin)
        } catch {
            return false
        }
    }

    func changePin(
        currentPin: String,
        newPin: String
    ) async -> Bool {
        do {
            let success = try await pinRepository.changePin(
                oldPin: currentPin,
                newPin: newPin
            )

            guard success else {
                errorMessage = "Unable to change PIN."
                return false
            }

            hasPin = true
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func signOut() async {
        guard !isSigningOut else { return }

        isSigningOut = true
        errorMessage = nil
        defer { isSigningOut = false }

        do {
            try await authRepository.signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func clearError() {
        errorMessage = nil
    }
}
