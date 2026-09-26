import SwiftUI

/// Large centered numeric input for entering a transfer amount, with a
/// currency label beside it. Used on TransferInput.
public struct AmountField: View {
    private let currencyCode: String
    @Binding private var amountText: String
    @FocusState private var isFocused: Bool

    public init(currencyCode: String = "VND", amountText: Binding<String>) {
        self.currencyCode = currencyCode
        self._amountText = amountText
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: AppSpacing.xs) {
            TextField("0", text: $amountText)
                .keyboardType(.decimalPad)
                .font(AppTypography.display)
                .foregroundStyle(Color.appOnSurface)
                .multilineTextAlignment(.center)
                .focused($isFocused)

            Text(currencyCode)
                .font(AppTypography.bodyMedium)
                .foregroundStyle(Color.appOnSurface.opacity(0.6))
        }
        .padding(.horizontal, AppSpacing.md)
        .frame(height: 64)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .strokeBorder(isFocused ? Color.appPrimaryContainer : Color.clear, lineWidth: 2)
        }
    }
}
