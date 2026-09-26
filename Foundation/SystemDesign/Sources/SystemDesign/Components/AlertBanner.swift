import SwiftUI

/// An inline banner for warnings or errors — e.g. "Insufficient
/// balance" on TransferInput, or a failed-lookup message.
public struct AlertBanner: View {
    public enum Style {
        case warning
        case error

        var background: Color {
            switch self {
            case .warning: return Color.appPrimaryContainer.opacity(0.3)
            case .error: return Color.appError.opacity(0.15)
            }
        }

        var foreground: Color {
            switch self {
            case .warning: return Color.appOnSurface
            case .error: return Color.appError
            }
        }

        var icon: String {
            switch self {
            case .warning: return "exclamationmark.triangle.fill"
            case .error: return "xmark.octagon.fill"
            }
        }
    }

    private let message: String
    private let style: Style

    public init(message: String, style: Style) {
        self.message = message
        self.style = style
    }

    public var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            Image(systemName: style.icon)
                .foregroundStyle(style.foreground)
            Text(message)
                .font(AppTypography.body)
                .foregroundStyle(style.foreground)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.sm)
        .background(style.background)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
    }
}
