import Authentication
import Domains
import Home
import SwiftUI

@main
struct SplitPayApp: App {
    private let container: AppContainer
    private let coordinator: AppCoordinator

    init() {
        let container = AppContainer()

        self.container = container
        self.coordinator = AppCoordinator(
            authRepository: container.resolve(IAuthRepository.self),
            walletRepository: container.resolve(IWalletRepository.self),
            transferRepository: container.resolve(ITransferRepository.self),
            profileRepository: container.resolve(IProfileRepository.self),
            pinRepository: container.resolve(IPinRepository.self),
            repaymentRepository: container.resolve(IRepaymentRepository.self),
            splitBillRepository: container.resolve(ISplitBillRepository.self),
            splitQRRepository: container.resolve(ISplitQRRepository.self)
        )

    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(coordinator)
        }
    }
}

private struct AppRootView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            switch coordinator.root {
            case .loading:
                ProgressView()
                    .task { coordinator.start() }

            case .unauthenticated:
                AuthCoordinator(
                    dependencies: .init(
                        authRepository: coordinator.authRepository
                    )
                )

            case .authenticated(let user):
                AppTabView()
            }
        }.onAppear {
            coordinator.start()
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else {
                return
            }

            coordinator.validateSession()
        }
    }
}
