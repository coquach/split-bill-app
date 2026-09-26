import Domains
import Observation

@MainActor
@Observable
public final class RegisterViewModel {

    public enum State: Equatable {
        case idle
        case loading
        case success
        case error(RegisterError)
    }

    public enum RegisterError: Equatable {
        case emptyEmail
        case invalidEmail
        case emptyPassword
        case weakPassword
        case passwordMismatch
        case emailAlreadyRegistered
        case network
        case unknown
    }

    public var email = ""
    public var password = ""
    public var confirmPassword = ""

    public private(set) var state: State = .idle

    private let authRepository: IAuthRepository

    public init(authRepository: IAuthRepository) {
        self.authRepository = authRepository
    }

    public func signUp() async {

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

        guard PasswordValidator.validate(password) else {
            state = .error(.weakPassword)
            return
        }

        guard password == confirmPassword else {
            state = .error(.passwordMismatch)
            return
        }

        state = .loading

        do {
            _ = try await authRepository.signUp(
                email: email,
                password: password
            )

            state = .success

        } catch {
            print("[RegisterViewModel] signUp failed: \(error)") // TODO: remove once map(_:) handles real errors
            state = .error(
                Self.map(error)
            )
        }
    }

    private static func map(
        _ error: Error
    ) -> RegisterError {
        .unknown
    }
}
