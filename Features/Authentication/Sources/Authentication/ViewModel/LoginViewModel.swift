import Combine
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

    var email = "" { didSet { edit(.email, emailSubject, email) } }
    var password = "" { didSet { edit(.password, passwordSubject, password) } }

    var emailError: String?
    var passwordError: String?

    private(set) var state: LoginState = .idle

    // Combine demo: same live validation as `RegisterViewModel` — the
    // pipeline owns the per-field error display and `canSubmit` (the Sign in
    // button's enabled state); the validation `signIn()` re-runs on submit
    // stays the source of truth for whether the repository is ever called.
    // A field's error shows only once that field has been touched, so the
    // untouched form opens clean; tapping Sign in touches all fields.
    private(set) var canSubmit = false

    private enum Field {
        case email, password
    }

    private var touched: Set<Field> = []
    private let touchedSubject = CurrentValueSubject<Set<Field>, Never>([])
    private let emailSubject = CurrentValueSubject<String, Never>("")
    private let passwordSubject = CurrentValueSubject<String, Never>("")
    private var cancellables = Set<AnyCancellable>()

    private let authRepository: IAuthRepository

    public init(authRepository: IAuthRepository) {
        self.authRepository = authRepository

        Publishers.CombineLatest(emailSubject, passwordSubject)
            .combineLatest(touchedSubject)
            .map { fields, touched in
                (LoginValidator.validate(
                    email: fields.0,
                    password: fields.1
                ), touched)
            }
            .sink { [weak self] validation, touched in
                guard let self else { return }
                // The sink closure is nonisolated, but `send()` only ever
                // fires from MainActor code (the `didSet` above and
                // `signIn()`) — assert that instead of writing @Observable
                // state from an unisolated context.
                MainActor.assumeIsolated {
                    // Show an error only for a field the user has already edited.
                    self.emailError = touched.contains(.email) ? validation.emailError : nil
                    self.passwordError = touched.contains(.password) ? validation.passwordError : nil
                    self.canSubmit = validation.isValid
                }
            }
            .store(in: &cancellables)
    }

    // Records the edit and fans it out to the validation pipeline. SwiftUI
    // can write the binding back with the *same* value when a field gains or
    // loses focus — that's not an edit, and counting it would flash the
    // "…is required." error the moment the user merely taps the field.
    private func edit<Value: Equatable>(_ field: Field, _ subject: CurrentValueSubject<Value, Never>, _ value: Value) {
        guard value != subject.value else { return }
        touched.insert(field)
        touchedSubject.send(touched)
        subject.send(value)
    }

    public func signIn() async {

        guard state != .submitting else {
               return
           }

        // Surface every remaining error, even for fields the user never
        // edited — the same feedback a submit used to give.
        touched = [.email, .password]
        touchedSubject.send(touched)

        let validation = LoginValidator.validate(
            email: email,
            password: password
        )

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

    func dismissError() {
        guard case .failure = state else {
            return
        }

        state = .idle
    }
}
