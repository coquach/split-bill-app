//
//  RegisterViewModelTests.swift
//  AuthenticationTests
//

@testable import Authentication
import Domains
import Foundation
import Testing

@Suite("RegisterViewModel")
@MainActor
struct RegisterViewModelTests {
    private let repository = MockAuthRepository()

    private func makeViewModel() -> RegisterViewModel {
        let viewModel = RegisterViewModel(authRepository: repository)
        viewModel.fullName = "An Nguyen"
        viewModel.phone = "0912345678"
        viewModel.email = "an@example.com"
        viewModel.password = "secret123"
        viewModel.confirmPassword = "secret123"
        return viewModel
    }

    @Test
    func aSuccessfulSignUpEndsInTheSuccessState() async {
        let viewModel = makeViewModel()

        await viewModel.signUp()

        #expect(viewModel.state == .success)
        #expect(repository.signUpCalls == 1)
    }

    @Test
    func theFieldsAreTrimmedBeforeTheyReachTheRepository() async {
        let viewModel = makeViewModel()
        viewModel.fullName = "  An Nguyen  "
        viewModel.phone = " 0912345678 "
        viewModel.email = " an@example.com "

        await viewModel.signUp()

        #expect(repository.lastSignUpEmail == "an@example.com")
        #expect(repository.lastSignUpFullName == "An Nguyen")
        #expect(repository.lastSignUpPhone == "0912345678")
        // The password is sent as typed — trimming it would change it.
        #expect(repository.lastSignUpPassword == "secret123")
    }

    @Test
    func anEmailAlreadyRegisteredFailureIsSurfaced() async {
        repository.signUpResult = .failure(AuthError.emailAlreadyRegistered)
        let viewModel = makeViewModel()

        await viewModel.signUp()

        #expect(viewModel.state == .failure(.emailAlreadyRegistered))
    }

    @Test
    func anUnknownErrorFallsBackToAuthErrorUnknown() async {
        struct SurprisingError: Error {}
        repository.signUpResult = .failure(SurprisingError())
        let viewModel = makeViewModel()

        await viewModel.signUp()

        #expect(viewModel.state == .failure(.unknown))
    }

    @Test
    func invalidInputNeverReachesTheRepositoryAndSetsEveryError() async {
        let viewModel = makeViewModel()
        viewModel.fullName = ""
        viewModel.phone = ""
        viewModel.email = ""
        viewModel.password = ""
        viewModel.confirmPassword = ""

        await viewModel.signUp()

        #expect(repository.signUpCalls == 0)
        #expect(viewModel.fullNameError == "Full name is required.")
        #expect(viewModel.phoneError == "Phone number is required.")
        #expect(viewModel.emailError == "Email is required.")
        #expect(viewModel.passwordError == "Password is required.")
        #expect(viewModel.confirmPasswordError == "Please confirm your password.")
        #expect(viewModel.state == .idle)
    }

    @Test
    func dismissEmailConfirmationReturnsToIdle() async {
        let viewModel = makeViewModel()
        await viewModel.signUp()
        #expect(viewModel.state == .success)

        viewModel.dismissEmailConfirmation()
        #expect(viewModel.state == .idle)
    }

    @Test
    func dismissErrorReturnsFromFailureToIdle() async {
        repository.signUpResult = .failure(AuthError.emailAlreadyRegistered)
        let viewModel = makeViewModel()

        await viewModel.signUp()
        viewModel.dismissError()

        #expect(viewModel.state == .idle)
    }

    @Test
    func dismissErrorOutsideOfFailureIsANoop() async {
        let viewModel = makeViewModel()

        viewModel.dismissError()
        #expect(viewModel.state == .idle)

        await viewModel.signUp()
        #expect(viewModel.state == .success)

        viewModel.dismissError()
        #expect(viewModel.state == .success)
    }

    @Test
    func aNewAttemptClearsThePreviousValidationErrors() async {
        let viewModel = makeViewModel()
        viewModel.email = "not-an-email"
        await viewModel.signUp()
        #expect(viewModel.emailError != nil)

        viewModel.email = "an@example.com"
        await viewModel.signUp()

        #expect(viewModel.emailError == nil)
        #expect(viewModel.state == .success)
    }

    // MARK: - Live validation

    // The pipeline's subjects fire synchronously on every edit, so the
    // assertions below need no await.

    @Test
    func theButtonIsDisabledUntilEveryFieldIsValid() {
        let viewModel = RegisterViewModel(authRepository: repository)
        #expect(!viewModel.canSubmit)

        viewModel.fullName = "An Nguyen"
        viewModel.phone = "0912345678"
        viewModel.email = "an@example.com"
        viewModel.password = "secret123"
        viewModel.confirmPassword = "secret123"

        #expect(viewModel.canSubmit)
    }

    @Test
    func anUntouchedFieldDoesNotShowItsError() {
        let viewModel = RegisterViewModel(authRepository: repository)
        viewModel.fullName = "An Nguyen"

        #expect(viewModel.fullNameError == nil)
        // Phone is empty and invalid, but the user never edited it — a fresh
        // form opens without a wall of "…is required." messages.
        #expect(viewModel.phoneError == nil)
        #expect(!viewModel.canSubmit)
    }

    @Test
    func anInvalidTouchedFieldShowsItsErrorLive() {
        let viewModel = RegisterViewModel(authRepository: repository)
        viewModel.email = "not-an-email"

        #expect(viewModel.emailError == "Please enter a valid email address.")
    }

    @Test
    func aValidTouchedFieldClearsItsErrorLive() {
        let viewModel = RegisterViewModel(authRepository: repository)
        viewModel.email = "not-an-email"
        #expect(viewModel.emailError != nil)

        viewModel.email = "an@example.com"

        #expect(viewModel.emailError == nil)
    }

    @Test
    func aSubmitOnAnUntouchedFormSurfacesEveryRequiredError() async {
        // No field has been edited, so nothing shows yet — submitting must
        // touch everything at once, restoring the old tap-to-show behavior
        // for anyone who reaches `signUp()` directly.
        let viewModel = RegisterViewModel(authRepository: repository)

        await viewModel.signUp()

        #expect(viewModel.fullNameError == "Full name is required.")
        #expect(viewModel.phoneError == "Phone number is required.")
        #expect(viewModel.emailError == "Email is required.")
        #expect(viewModel.passwordError == "Password is required.")
        #expect(viewModel.confirmPasswordError == "Please confirm your password.")
        #expect(repository.signUpCalls == 0)
        #expect(viewModel.state == .idle)
    }
}
