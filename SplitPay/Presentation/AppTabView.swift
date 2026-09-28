import Home
//
//  AppTabView.swift
//  SplitPay
//
//  Created by Co Quach on 28/9/26.
//
import SwiftUI
import SystemDesign

struct AppTabView: View {
    enum Tab: Hashable {
        case home
        case transfer
        case splitBill
        case profile
    }

    @Environment(AppCoordinator.self) private var coordinator

    @State private var selectedTab: Tab = .home
    @State private var isShowingScanner = false

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeCoordinator(
                    dependencies: .init(
                        profileRepository: coordinator.profileRepository,
                        walletRepository: coordinator.walletRepository,
                        transferRepository: coordinator.transferRepository
                    )
                )
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(Tab.home)

                NavigationStack {
                    PlaceholderScreen(
                        title: "Transfer",
                        systemImage: "arrow.left.arrow.right"
                    )
                }
                .tabItem {
                    Label("Transfer", systemImage: "arrow.left.arrow.right")
                }
                .toolbarBackground(
                    Color.appPrimary,
                    for: .tabBar
                )
                .tag(Tab.transfer)

                NavigationStack {
                    PlaceholderScreen(
                        title: "Split Bill",
                        systemImage: "person.2.fill"
                    )
                }
                .tabItem {
                    Label("Split Bill", systemImage: "person.2.fill")
                }
                .tag(Tab.splitBill)

                NavigationStack {
                    PlaceholderScreen(
                        title: "Profile",
                        systemImage: "person.fill"
                    )
                }
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
        .sheet(isPresented: $isShowingScanner) {
            NavigationStack {
                ScanQRView()
            }
        }
    }
}

private struct PlaceholderScreen: View {
    let title: String
    let systemImage: String

    var body: some View {
        ContentUnavailableView(title, systemImage: systemImage)
            .navigationTitle(title)
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

private struct ScanQRView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "qrcode.viewfinder")
                .font(.system(size: 64))
            Text("Scan QR")
                .font(.title2.bold())
            Text(
                "The in-app scanner will decode the Split Bill QR payload here."
            )
            .multilineTextAlignment(.center)
            .foregroundStyle(.secondary)
        }
        .padding(32)
        .navigationTitle("Scan QR")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Close") { dismiss() }
            }
        }
    }
}
