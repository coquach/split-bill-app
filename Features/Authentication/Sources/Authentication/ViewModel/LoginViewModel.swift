import Domains
import Observation

@MainActor
@Observable
public final class LoginViewModel {

    enum LoginState: Equatable {
        case idle
        case submitting
        case success
        case failure(AuthError)
    }

    var email = ""
    var password = ""

    var emailError: String?
    var passwordError: String?

    private(set) var state: LoginState = .idle

    private let authRepository: IAuthRepository

    public init(authRepository: IAuthRepository) {
        self.authRepository = authRepository
    }

    public func signIn() async {

        guard state != .submitting else {
               return
           }
        
        clearError()

        let validation = LoginValidator.validate(
            email: email,
            password: password
        )

        emailError = validation.emailError
        passwordError = validation.passwordError

        guard validation.isValid else {
            return
        }

        state = .submitting

        do {
            _ = try await authRepository.signIn(
                email: email.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ),
                password: password
            )

            state = .success

        } catch let error as AuthError {
            state = .failure(error)

        } catch {
            state = .failure(.unknown)
        }
    }

    private func clearError() {
        emailError = nil
        passwordError = nil
    }

    func dismissError() {
        guard case .failure = state else {
            return
        }

        state = .idle
    }
}
