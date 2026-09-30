//
//  AppTabView.swift
//  SplitPay
//
//  Created by Co Quach on 28/9/26.
//

import Domains
import Home
import Profile
import Router
import SplitBill
import SwiftUI
import SystemDesign
import Transfer

struct AppTabView: View {
    enum Tab: Hashable {
        case home
        case transfer
        case splitBill
        case profile
    }

    @Environment(AppCoordinator.self) private var coordinator

    @State private var selectedTab: Tab = .home
    @State private var isTransferPresented = false
    @State private var isShowingScanner = false

    // Held here, not inside the coordinators, so switching tabs can reset
    // each one's navigation stack back to its entry screen.
    @State private var transferRouter = Router()
    @State private var splitRouter = Router()

    // Non-nil while Split is open on a specific transaction, reached from
    // Transaction Detail inside the Transfer tab.
    @State private var splitSource: SplitSource?

    private var splitDependencies: SplitBillCoordinator.Dependencies {
        .init(
            splitBillRepository: coordinator.splitBillRepository,
            splitQRRepository: coordinator.splitQRRepository,
            repaymentRepository: coordinator.repaymentRepository
        )
    }

    // Home and Profile never push, so they're always at their root.
    private var isSelectedTabAtRoot: Bool {
        switch selectedTab {
        case .home, .profile: return true
        case .transfer: return transferRouter.navPath.isEmpty
        case .splitBill: return splitRouter.navPath.isEmpty
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeCoordinator(
                    dependencies: .init(
                        profileRepository: coordinator.profileRepository,
                        walletRepository: coordinator.walletRepository,
                        transferRepository: coordinator.transferRepository
                    ),
                    onTransfer: { isTransferPresented = true },
                    onSplitBill: { selectedTab = .splitBill },
                    onTransactionHistory: { selectedTab = .transfer }
                )
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(Tab.home)

                TransferCoordinator(
                    entry: .history,
                    router: transferRouter,
                    dependencies: .init(
                        walletRepository: coordinator.walletRepository,
                        sessionStore: coordinator.sessionStore,
                        transferRepository: coordinator.transferRepository
                    ),
                    onFinish: { selectedTab = .home },
                    onSplitBill: { source in splitSource = source }
                )
                .tabItem {
                    Label("History", systemImage: "arrow.left.arrow.right")
                }
                .tag(Tab.transfer)

                SplitBillCoordinator(
                    entry: .history,
                    router: splitRouter,
                    dependencies: splitDependencies,
                    onFinish: { selectedTab = .home }
                )
                .tabItem {
                    Label("Split", systemImage: "person.2.fill")
                }
                .tag(Tab.splitBill)

                ProfileCoordinator(
                    dependencies: .init(
                        profileRepository: coordinator.profileRepository,
                        pinRepository: coordinator.pinRepository,
                        authRepository: coordinator.authRepository
                    )
                )
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(Tab.profile)
            }

            if isSelectedTabAtRoot {
                ScanQRButton {
                    isShowingScanner = true
                }
                .offset(y: -30)
            }
        }
        .tint(Color.appPrimary)
        .toolbarBackground(
            Color.appBackground,
            for: .tabBar
        )
        .toolbarBackground(
            .visible,
            for: .tabBar
        )
        .onChange(of: selectedTab) { _, newTab in
            switch newTab {
            case .home, .profile:
                break
            case .transfer:
                transferRouter.navigateToRoot()
            case .splitBill:
                splitRouter.navigateToRoot()
            }
        }
        .fullScreenCover(isPresented: $isTransferPresented) {
            TransferCoordinator(
                entry: .flow,
                dependencies: .init(
                    walletRepository: coordinator.walletRepository,
                    sessionStore: coordinator.sessionStore,
                    transferRepository: coordinator.transferRepository
                ),
                onFinish: {
                    isTransferPresented = false
                    coordinator.refreshBalance()
                },
                onSplitBill: { source in splitSource = source }
            )
            .fullScreenCover(item: $splitSource) { source in
                SplitBillCoordinator(
                    entry: .create(source),
                    dependencies: splitDependencies,
                    // Dismiss both covers so Home on the Split QR screen lands
                    // on the Home tab, not back on the Transfer flow underneath.
                    onFinish: {
                        splitSource = nil
                        isTransferPresented = false
                        selectedTab = .home
                        coordinator.refreshBalance()
                    }
                )
            }
        }
        .fullScreenCover(isPresented: $isShowingScanner) {
            SplitBillCoordinator(
                entry: .repay,
                dependencies: splitDependencies,
                onFinish: { isShowingScanner = false }
            )
        }
    }
}

private struct ScanQRButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "qrcode.viewfinder")
                .font(.system(size: 27, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background {
                    Circle()
                        .fill(Color.appPrimary)
                }
                .overlay {
                    Circle()
                        .stroke(.background, lineWidth: 4)
                }
                .shadow(
                    color: .black.opacity(0.18),
                    radius: 8,
                    y: 4
                )
        }
        .accessibilityLabel("Scan QR")
    }
}
