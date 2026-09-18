import Domains
import Observation

@Observable
@MainActor
public final class LoginViewModel {
    public enum State {
        case idle
        case loading
        case error(String)
    }

    public var email = ""
    public var password = ""
    public var state: State = .idle

    private let authRepository: IAuthRepository

    public init(authRepository: IAuthRepository) {
        self.authRepository = authRepository
    }

    public func signIn() async {
        guard !email.isEmpty, !password.isEmpty else {
            state = .error("Email và mật khẩu không được để trống")
            return
        }
        state = .loading
        do {
            _ = try await authRepository.signIn(email: email, password: password)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
