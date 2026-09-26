import SwiftUI

/// A centered icon + title + message shown when a list has nothing to
/// display — e.g. Transaction History or Split List with no entries yet.
public struct EmptyStateView: View {
    private let icon: String
    private let title: String
    private let message: String

    public init(icon: String, title: String, message: String) {
        self.icon = icon
        self.title = title
        self.message = message
    }

    public var body: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(Color.appOnSurface.opacity(0.3))

            Text(title)
                .font(AppTypography.bodyMedium)
                .foregroundStyle(Color.appOnSurface)

            Text(message)
                .font(AppTypography.body)
                .foregroundStyle(Color.appOnSurface.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.xl)
    }
}
