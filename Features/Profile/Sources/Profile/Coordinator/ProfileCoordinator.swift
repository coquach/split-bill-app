import Domains
import SwiftUI

public struct ProfileCoordinator: View {
    private let dependencies: Dependencies

    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    public var body: some View {
        NavigationStack {
            ProfileView(
                viewModel: ProfileViewModel(
                    profileRepository: dependencies.profileRepository,
                    pinRepository: dependencies.pinRepository,
                    authRepository: dependencies.authRepository
                )
            )
        }
    }
}

extension ProfileCoordinator {
    public struct Dependencies {
        let profileRepository: IProfileRepository
        let pinRepository: IPinRepository
        let authRepository: IAuthRepository

        public init(
            profileRepository: IProfileRepository,
            pinRepository: IPinRepository,
            authRepository: IAuthRepository
        ) {
            self.profileRepository = profileRepository
            self.pinRepository = pinRepository
            self.authRepository = authRepository
        }
    }
}
