import SwiftUI

/// Large centered numeric input for entering a transfer amount, with a
/// currency label beside it. Used on TransferInput.
public struct AmountField: View {
    private let currencyCode: String
    private let accessibilityID: String?
    @Binding private var amountText: String
    @FocusState private var isFocused: Bool
    @State private var displayText: String = ""

    public init(
        currencyCode: String = "VND",
        amountText: Binding<String>,
        accessibilityID: String? = nil
    ) {
        self.currencyCode = currencyCode
        self._amountText = amountText
        self.accessibilityID = accessibilityID
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: AppSpacing.xs) {
            TextField("0", text: $displayText)
                .keyboardType(.decimalPad)
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(Color.appError)
                .multilineTextAlignment(.center)
                .focused($isFocused)
                .accessibilityID(accessibilityID)
                .onChange(of: displayText) { _, newValue in
                    let digits = newValue.filter(\.isNumber)
                    if digits != amountText {
                        amountText = digits
                    }
                    let formatted = Self.formattedWithCommas(digits)
                    if formatted != displayText {
                        displayText = formatted
                    }
                }

            Text(currencyCode)
                .font(AppTypography.bodyMedium)
                .foregroundStyle(Color.appOnSurface.opacity(0.6))
        }
        .padding(.horizontal, AppSpacing.md)
        .frame(height: 100)
        .frame(maxWidth: .infinity)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 3)
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .strokeBorder(isFocused ? Color.appOnSurface : Color.clear, lineWidth: 2)
        }
        .onAppear {
            displayText = Self.formattedWithCommas(amountText)
        }
        .onChange(of: amountText) { _, newValue in
            let formatted = Self.formattedWithCommas(newValue)
            if formatted != displayText {
                displayText = formatted
            }
        }
    }

    // "123213" -> "123,213". Keeps the underlying bound amountText as
    // plain digits (what the rest of the app parses as a number) while
    // showing grouped digits to the user.
    private static func formattedWithCommas(_ raw: String) -> String {
        guard let value = Int(raw), value > 0 else {
            return raw.isEmpty ? "" : raw
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: value)) ?? raw
    }
}
