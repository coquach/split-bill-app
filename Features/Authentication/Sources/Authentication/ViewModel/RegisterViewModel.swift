import Domains
import Observation

@MainActor
@Observable
public final class RegisterViewModel {

    public enum ValidationError: Equatable {
        case emptyEmail
        case invalidEmail
        case emptyPassword
        case weakPassword
        case passwordMismatch
    }

    public enum State: Equatable {
        case idle
        case loading
        case success
        case validation(ValidationError)
        case auth(AuthError)
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
            state = .validation(.emptyEmail)
            return
        }

        guard EmailValidator.validate(email) else {
            state = .validation(.invalidEmail)
            return
        }

        guard !password.isEmpty else {
            state = .validation(.emptyPassword)
            return
        }

        guard PasswordValidator.validate(password) else {
            state = .validation(.weakPassword)
            return
        }

        guard password == confirmPassword else {
            state = .validation(.passwordMismatch)
            return
        }

        state = .loading

        do {
            _ = try await authRepository.signUp(
                email: email,
                password: password
            )

            state = .success

        } catch let error as AuthError {
            state = .auth(error)

        } catch {
            state = .auth(.unknown)
        }
    }
}
