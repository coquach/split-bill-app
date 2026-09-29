import Home
//
//  AppTabView.swift
//  SplitPay
//
//  Created by Co Quach on 28/9/26.
//
import SwiftUI
import SystemDesign
import Profile
import Transfer
import SplitBill
import Domains

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
                    dependencies: .init(
                        walletRepository: coordinator.walletRepository,
                        sessionStore: coordinator.sessionStore,
                        transferRepository: coordinator.transferRepository
                    ),
                    onFinish: { selectedTab = .home },
                    onSplitBill: { source in splitSource = source }
                )
                .tabItem {
                    Label("Transfer", systemImage: "arrow.left.arrow.right")
                }
                .toolbarBackground(
                    Color.appPrimary,
                    for: .tabBar
                )
                .tag(Tab.transfer)

                SplitBillCoordinator(
                    entry: .history,
                    dependencies: splitDependencies,
                    onFinish: { selectedTab = .home }
                )
                .tabItem {
                    Label("Split Bill", systemImage: "person.2.fill")
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

            ScanQRButton {
                isShowingScanner = true
            }
            .offset(x: 0, y: -30)
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
                    onFinish: { splitSource = nil }
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
                        .fill(Color.accentColor)
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
