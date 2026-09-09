import SwiftUI

/// Full-width action button (e.g. "Continue", "Confirm & Send", "Generate QR"). Now backed
/// by the system `.glassProminent` button style instead of a hand-drawn filled capsule —
/// Liquid Glass handles the material, tint response, and the press/hover morph animation
/// for us; we just supply the tint, label, and loading/disabled state.
struct PrimaryButton: View {
    let title: String
    var systemImage: String?
    var isLoading: Bool = false
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                } else if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
                    .font(Theme.Typography.title)
            }
            .frame(maxWidth: .infinity)
            .frame(height: Theme.Spacing.rowMinHeight)
        }
        .buttonStyle(.glassProminent)
        .tint(Theme.Colors.primary)
        .foregroundStyle(Theme.Colors.accent)
        .disabled(!isEnabled || isLoading)
        .opacity(isEnabled ? 1 : 0.5)
        .accessibilityLabel(title)
    }
}

/// Outlined/secondary action — "Cancel", "Download QR", "Copy Deeplink" — rendered with the
/// non-prominent `.glass` style so it reads as lighter weight than `PrimaryButton` while
/// still picking up the same Liquid Glass material.
struct SecondaryButton: View {
    let title: String
    var systemImage: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
                    .font(Theme.Typography.body.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: Theme.Spacing.rowMinHeight - 8)
        }
        .buttonStyle(.glass)
        .tint(Theme.Colors.primary)
        .accessibilityLabel(title)
    }
}
