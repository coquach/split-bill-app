import SwiftUI

public struct RegisterView: View {
    @State private var viewModel: RegisterViewModel
    let onNavigateToLogin: () -> Void

    public init(viewModel: RegisterViewModel, onNavigateToLogin: @escaping () -> Void) {
        self._viewModel = State(initialValue: viewModel)
        self.onNavigateToLogin = onNavigateToLogin
    }

    public var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Đăng ký")
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

                SecureField("Xác nhận mật khẩu", text: $viewModel.confirmPassword)
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
                Task { await viewModel.signUp() }
            } label: {
                Group {
                    if case .loading = viewModel.state {
                        ProgressView()
                    } else {
                        Text("Đăng ký")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled({
                if case .loading = viewModel.state { return true }
                return false
            }())

            Button("Đã có tài khoản? Đăng nhập", action: onNavigateToLogin)
                .font(.subheadline)

            Spacer()
        }
        .padding(.horizontal, 24)
    }
}
