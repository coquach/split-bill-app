import SwiftUI

/// A multi-line text box for optional notes — e.g. the transfer
/// description field on TransferInput.
public struct AppMultilineTextField: View {
    private let placeholder: String
    @Binding private var text: String
    @FocusState private var isFocused: Bool

    public init(placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            // TextEditor has no built-in placeholder text, unlike TextField,
            // so we draw our own and hide it once the user has typed anything.
            if text.isEmpty {
                Text(placeholder)
                    .font(AppTypography.body)
                    .foregroundStyle(Color.appOnSurface.opacity(0.4))
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.sm)
            }

            TextEditor(text: $text)
                .font(AppTypography.body)
                .foregroundStyle(Color.appOnSurface)
                .scrollContentBackground(.hidden) // removes TextEditor's default white background
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.xxs)
                .focused($isFocused)
        }
        .frame(height: 88)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .strokeBorder(isFocused ? Color.appPrimaryContainer : Color.clear, lineWidth: 2)
        }
    }
}
