import Domains
import Observation

@MainActor
@Observable
public final class LoginViewModel {

    public enum ValidationError: Equatable {
        case emptyEmail
        case invalidEmail
        case emptyPassword
    }

    public enum State: Equatable {
        case idle
        case loading
        case validation(ValidationError)
        case auth(AuthError)
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

        state = .loading

        do {
            _ = try await authRepository.signIn(
                email: email,
                password: password
            )

            state = .idle

        } catch let error as AuthError {
            state = .auth(error)

        } catch {
            state = .auth(.unknown)
        }
    }
}
