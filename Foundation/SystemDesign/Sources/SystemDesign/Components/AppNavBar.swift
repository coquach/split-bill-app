//
//  AppNavBar.swift
//  SystemDesign
//
//  Created by Dinh Long on 28/9/26.
//

import SwiftUI

/// The in-app navigation bar for the Transfer flow.
///
/// Screens draw this themselves instead of using SwiftUI's own bar
/// (`.navigationTitle`), because the system bar brings its own material and
/// background that doesn't match `appBackground` — which is exactly what made
/// one screen look like it had a white strip while its neighbours didn't.
///
/// Pair it with `.navigationBarHidden(true)` and attach it as a top
/// `safeAreaInset`, so it stays pinned while content scrolls under it.
public struct AppNavBar: View {
    private let title: String
    private let onBack: (() -> Void)?

    /// Pass `onBack: nil` for a screen with no way back — the leading slot
    /// still reserves its width so the title stays centred.
    public init(title: String, onBack: (() -> Void)? = nil) {
        self.title = title
        self.onBack = onBack
    }

    public var body: some View {
        HStack {
            if let onBack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color.appOnSurface)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
            } else {
                slot
            }

            Spacer()

            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.appOnSurface)

            Spacer()

            // Mirrors the leading control so the title sits optically centred
            // rather than being pushed right by the chevron.
            slot
        }
        .padding(.horizontal, AppSpacing.xs)
        .frame(height: 44)
        .background(Color.appBackground)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.black.opacity(0.05))
                .frame(height: 1)
                .blur(radius: 2)
                .offset(y: 2)
        }
    }

    private var slot: some View {
        Color.clear.frame(width: 44, height: 44)
    }
}
