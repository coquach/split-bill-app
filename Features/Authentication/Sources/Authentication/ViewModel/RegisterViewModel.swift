import Domains
import Observation

@Observable
@MainActor
public final class RegisterViewModel {
    public enum State {
        case idle
        case loading
        case success
        case error(String)
    }

    public var email = ""
    public var password = ""
    public var confirmPassword = ""
    public var state: State = .idle

    private let authRepository: IAuthRepository

    public init(authRepository: IAuthRepository) {
        self.authRepository = authRepository
    }

    public func signUp() async {
        guard !email.isEmpty, !password.isEmpty else {
            state = .error("Email và mật khẩu không được để trống")
            return
        }
        guard password == confirmPassword else {
            state = .error("Mật khẩu xác nhận không khớp")
            return
        }
        state = .loading
        do {
            _ = try await authRepository.signUp(email: email, password: password)
            state = .success
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
