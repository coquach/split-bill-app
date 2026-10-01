import Combine
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

    var fullName = "" { didSet { edit(.fullName, fullNameSubject, fullName) } }
    var phone = "" { didSet { edit(.phone, phoneSubject, phone) } }
    var email = "" { didSet { edit(.email, emailSubject, email) } }
    var password = "" { didSet { edit(.password, passwordSubject, password) } }
    var confirmPassword = "" {
        didSet { edit(.confirmPassword, confirmPasswordSubject, confirmPassword) }
    }

    var fullNameError: String?
    var phoneError: String?
    var emailError: String?
    var passwordError: String?
    var confirmPasswordError: String?

    private(set) var state: RegisterState = .idle

    // Combine demo: live validation as the user types. The pipeline owns the
    // per-field error display and `canSubmit` (the Sign Up button's enabled
    // state); the validation `signUp()` re-runs on submit stays the source of
    // truth for whether the repository is ever called.
    //
    // A field's error shows only once that field has been touched (edited at
    // least once) — otherwise the untouched, empty form would open with every
    // "…is required." message already visible. Tapping Sign Up touches all
    // fields, so remaining errors surface exactly like the old submit-time
    // display did.
    private(set) var canSubmit = false

    private enum Field {
        case fullName, phone, email, password, confirmPassword
    }

    private var touched: Set<Field> = []
    private let touchedSubject = CurrentValueSubject<Set<Field>, Never>([])
    private let fullNameSubject = CurrentValueSubject<String, Never>("")
    private let phoneSubject = CurrentValueSubject<String, Never>("")
    private let emailSubject = CurrentValueSubject<String, Never>("")
    private let passwordSubject = CurrentValueSubject<String, Never>("")
    private let confirmPasswordSubject = CurrentValueSubject<String, Never>("")
    private var cancellables = Set<AnyCancellable>()

    private let authRepository: IAuthRepository

    public init(authRepository: IAuthRepository) {
        self.authRepository = authRepository

        Publishers.CombineLatest4(
            fullNameSubject, phoneSubject, emailSubject, passwordSubject
        )
        .combineLatest(confirmPasswordSubject, touchedSubject)
        .map { fields, confirmPassword, touched in
            let (fullName, phone, email, password) = fields
            return (RegisterValidator.validate(
                fullName: fullName,
                phone: phone,
                email: email,
                password: password,
                confirmPassword: confirmPassword
            ), touched)
        }
        .sink { [weak self] validation, touched in
            guard let self else { return }
            // The sink closure is nonisolated, but `send()` only ever fires
            // from MainActor code (the `didSet` above and `signUp()`) —
            // assert that instead of writing @Observable state from an
            // unisolated context.
            MainActor.assumeIsolated {
                // Show an error only for a field the user has already edited.
                self.fullNameError = touched.contains(.fullName) ? validation.fullNameError : nil
                self.phoneError = touched.contains(.phone) ? validation.phoneError : nil
                self.emailError = touched.contains(.email) ? validation.emailError : nil
                self.passwordError = touched.contains(.password) ? validation.passwordError : nil
                self.confirmPasswordError = touched.contains(.confirmPassword)
                    ? validation.confirmPasswordError : nil
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

    public func signUp() async {
        guard state != .submitting else {
            return
        }

        // Surface every remaining error, even for fields the user never
        // edited — the same feedback a submit used to give.
        touched = [.fullName, .phone, .email, .password, .confirmPassword]
        touchedSubject.send(touched)

        let validation = RegisterValidator.validate(
            fullName: fullName,
            phone: phone,
            email: email,
            password: password,
            confirmPassword: confirmPassword
        )

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
