import Domains
import Observation

@MainActor
@Observable
public final class RegisterViewModel {

    enum RegisterState: Equatable {
        case idle
        case submitting
        case success
        case failure(AuthError)
    }

    var fullName = ""
    var phone = ""
    var email = ""
    var password = ""
    var confirmPassword = ""

    var fullNameError: String?
    var phoneError: String?
    var emailError: String?
    var passwordError: String?
    var confirmPasswordError: String?

    private(set) var state: RegisterState = .idle

    private let authRepository: IAuthRepository

    public init(authRepository: IAuthRepository) {
        self.authRepository = authRepository
    }

    public func signUp() async {
        guard state != .submitting else {
            return
        }
        clearErrors()

        let validation = RegisterValidator.validate(
            fullName: fullName,
            phone: phone,
            email: email,
            password: password,
            confirmPassword: confirmPassword
        )

        fullNameError = validation.fullNameError
        phoneError = validation.phoneError
        emailError = validation.emailError
        passwordError = validation.passwordError
        confirmPasswordError = validation.confirmPasswordError

        guard validation.isValid else {
            return
        }

        state = .submitting

        do {
            _ =  try await authRepository.signUp(
                email: email.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ),
                password: password,
                fullName: fullName.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ),
                phone: phone.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
            )

            state = .success

        } catch let error as AuthError {

            state = .failure(error)

        } catch {

            state = .failure(.unknown)
        }
    }

    private func clearErrors() {
        fullNameError = nil
        phoneError = nil
        emailError = nil
        passwordError = nil
        confirmPasswordError = nil
    }
    
    func dismissEmailConfirmation() {
        state = .idle
    }
    
    func dismissError() {
        guard case .failure = state else {
            return
        }

        state = .idle
    }
}
