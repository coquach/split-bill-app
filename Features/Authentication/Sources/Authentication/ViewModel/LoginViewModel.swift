import Domains
import Observation

@MainActor
@Observable
final class LoginViewModel {

    public enum State: Equatable {
        case idle
        case loading
        case error(LoginError)
    }

    public enum LoginError: Equatable {
        case emptyEmail
        case invalidEmail
        case emptyPassword
        case invalidCredentials
        case emailNotConfirmed
        case network
        case unknown
    }

    public var email = ""
    public var password = ""
    public private(set) var state: State = .idle

    private let authRepository: IAuthRepository

    public init(authRepository: IAuthRepository) {
        self.authRepository = authRepository
    }

    public func signIn() async {

        guard state != .loading else {
            return
        }

        let email = email.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !email.isEmpty else {
            state = .error(.emptyEmail)
            return
        }

        guard EmailValidator.validate(email) else {
            state = .error(.invalidEmail)
            return
        }

        guard !password.isEmpty else {
            state = .error(.emptyPassword)
            return
        }

        state = .loading

        do {
            _ = try await authRepository.signIn(
                email: email,
                password: password
            )

            state = .idle

        } catch {
            state = .error(
                Self.map(error)
            )
        }
    }

    private static func map(_ error: Error) -> LoginError {
        // map domain/backend errors
        .unknown
    }
}


