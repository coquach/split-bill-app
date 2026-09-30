//
//  LoginViewModelTests.swift
//  AuthenticationTests
//

@testable import Authentication
import Domains
import Foundation
import Testing

@Suite("LoginViewModel")
@MainActor
struct LoginViewModelTests {
    private let repository = MockAuthRepository()

    private func makeViewModel() -> LoginViewModel {
        LoginViewModel(authRepository: repository)
    }

    @Test
    func aSuccessfulSignInEndsInTheSuccessState() async {
        let viewModel = makeViewModel()
        viewModel.email = "an@example.com"
        viewModel.password = "secret123"

        await viewModel.signIn()

        #expect(viewModel.state == .success)
        #expect(repository.signInCalls == 1)
        #expect(repository.lastSignInEmail == "an@example.com")
        #expect(repository.lastSignInPassword == "secret123")
    }

    @Test
    func theEmailIsTrimmedBeforeItReachesTheRepository() async {
        let viewModel = makeViewModel()
        viewModel.email = "  an@example.com  "
        viewModel.password = "secret123"

        await viewModel.signIn()

        #expect(repository.lastSignInEmail == "an@example.com")
    }

    @Test
    func anInvalidCredentialsFailureIsSurfaced() async {
        repository.signInResult = .failure(AuthError.invalidCredentials)
        let viewModel = makeViewModel()
        viewModel.email = "an@example.com"
        viewModel.password = "wrong-password"

        await viewModel.signIn()

        #expect(viewModel.state == .failure(.invalidCredentials))
    }

    @Test
    func anUnknownErrorFallsBackToAuthErrorUnknown() async {
        struct SurprisingError: Error {}
        repository.signInResult = .failure(SurprisingError())
        let viewModel = makeViewModel()
        viewModel.email = "an@example.com"
        viewModel.password = "secret123"

        await viewModel.signIn()

        #expect(viewModel.state == .failure(.unknown))
    }

    @Test
    func invalidInputNeverReachesTheRepository() async {
        let viewModel = makeViewModel()
        viewModel.email = ""
        viewModel.password = ""

        await viewModel.signIn()

        #expect(repository.signInCalls == 0)
        #expect(viewModel.emailError == "Email is required.")
        #expect(viewModel.passwordError == "Password is required.")
        #expect(viewModel.state == .idle)
    }

    @Test
    func aSecondSubmitWhileInFlightIsANoop() async {
        repository.holdSignIn = true
        let viewModel = makeViewModel()
        viewModel.email = "an@example.com"
        viewModel.password = "secret123"

        async let first: Void = viewModel.signIn()
        while repository.signInCalls == 0 {
            await Task.yield()
        }

        async let second: Void = viewModel.signIn()
        await second

        repository.resumeSignIn(.success(makeUser()))
        await first

        #expect(repository.signInCalls == 1)
        #expect(viewModel.state == .success)
    }

    @Test
    func dismissErrorReturnsFromFailureToIdle() async {
        repository.signInResult = .failure(AuthError.invalidCredentials)
        let viewModel = makeViewModel()
        viewModel.email = "an@example.com"
        viewModel.password = "wrong"

        await viewModel.signIn()
        #expect(viewModel.state == .failure(.invalidCredentials))

        viewModel.dismissError()
        #expect(viewModel.state == .idle)
    }

    @Test
    func dismissErrorOutsideOfFailureIsANoop() async {
        let viewModel = makeViewModel()

        viewModel.dismissError()
        #expect(viewModel.state == .idle)

        viewModel.email = "an@example.com"
        viewModel.password = "secret123"
        await viewModel.signIn()
        #expect(viewModel.state == .success)

        viewModel.dismissError()
        #expect(viewModel.state == .success)
    }

    @Test
    func aNewAttemptClearsThePreviousValidationErrors() async {
        let viewModel = makeViewModel()
        viewModel.email = ""
        viewModel.password = ""
        await viewModel.signIn()
        #expect(viewModel.emailError != nil)

        viewModel.email = "an@example.com"
        viewModel.password = "secret123"
        await viewModel.signIn()

        #expect(viewModel.emailError == nil)
        #expect(viewModel.passwordError == nil)
    }
}
