import Domains
import Router
import SwiftUI

public enum AuthDestination: Hashable {
    case register
}

public struct AuthCoordinator: View {
    @State private var router = Router()
    private let dependencies: Dependencies

    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    public var body: some View {
        NavigationStack(path: $router.navPath) {
            LoginView(
                viewModel: LoginViewModel(
                    authRepository: dependencies.authRepository
                ),
                onNavigateToRegister: {
                    router.navigate(to: AuthDestination.register)
                }
            )
            .navigationDestination(for: AuthDestination.self) { destination in
                switch destination {
                case .register:
                    RegisterView(
                        viewModel: RegisterViewModel(
                            authRepository: dependencies.authRepository
                        ),
                        onNavigateToLogin: { router.navigateBack() }
                    )
                }
            }
        }
        .environment(router)
    }
}

extension AuthCoordinator {
    public struct Dependencies {
        let authRepository: IAuthRepository

        public init(authRepository: IAuthRepository) {
            self.authRepository = authRepository
        }
    }
}
