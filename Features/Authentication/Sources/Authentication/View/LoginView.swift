import SwiftUI

public struct LoginView: View {
    @State private var viewModel: LoginViewModel
    let onNavigateToRegister: () -> Void

    public init(viewModel: LoginViewModel, onNavigateToRegister: @escaping () -> Void) {
        self._viewModel = State(initialValue: viewModel)
        self.onNavigateToRegister = onNavigateToRegister
    }

    public var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Đăng nhập")
                .font(.largeTitle.bold())

            VStack(spacing: 16) {
                TextField("Email", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                SecureField("Mật khẩu", text: $viewModel.password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            if case .error(let message) = viewModel.state {
                Text(message)
                    .foregroundStyle(.red)
                    .font(.caption)
            }

            Button {
                Task { await viewModel.signIn() }
            } label: {
                Group {
                    if case .loading = viewModel.state {
                        ProgressView()
                    } else {
                        Text("Đăng nhập")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(viewModel.state == .loading)

            Button("Chưa có tài khoản? Đăng ký", action: onNavigateToRegister)
                .font(.subheadline)

            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

private extension LoginViewModel.State {
    static func == (lhs: LoginViewModel.State, rhs: LoginViewModel.State) -> Bool {
        if case .loading = lhs, case .loading = rhs { return true }
        return false
    }
}
