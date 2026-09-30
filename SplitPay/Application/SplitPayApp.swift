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
            splitQRRepository: container.resolve(ISplitQRRepository.self),
            sessionStore: container.resolve(SessionStore.self)
        )

    }

    /// UI tests skip the ~1.45s splash animation so launches are fast and
    /// XCUITest queries don't race the overlay window.
    private var launchScreenConfig: LaunchScreenConfig {
        var config = LaunchScreenConfig(forceHideLogo: false)
        #if DEBUG
        if UITestConfig.isEnabled {
            config.initialDelay = 0
            config.animation = .smooth(duration: 0.05, extraBounce: 0)
        }
        #endif
        return config
    }

    var body: some Scene {
        LaunchScreen(config: launchScreenConfig) {
            Image("AppIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
        } rootContent: {
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
