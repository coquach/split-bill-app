import SwiftUI

public struct OTPCodeInput: View {
    private let length: Int
    private let isKeyboardDriven: Bool
    @Binding private var code: String
    @FocusState private var isFocused: Bool

    public init(length: Int = 6, code: Binding<String>, isKeyboardDriven: Bool = true) {
        self.length = length
        self._code = code
        self.isKeyboardDriven = isKeyboardDriven
    }

    public var body: some View {
        ZStack {
            HStack(spacing: AppSpacing.sm) {
                ForEach(0..<length, id: \.self) { index in
                    box(at: index)
                }
            }

            if isKeyboardDriven {
                TextField("", text: $code)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .foregroundStyle(.clear)
                    .tint(.clear)
                    .focused($isFocused)
                    .onChange(of: code) { _, newValue in
                        // Keep digits only, then clamp to `length`. The
                        // numberPad can't produce anything else, but a
                        // hardware keyboard (and the Simulator) can, and a
                        // PIN that quietly contains a letter would be
                        // rejected by the backend with no obvious cause.
                        let digits = newValue.filter(\.isNumber)
                        let clamped = String(digits.prefix(length))
                        if clamped != newValue {
                            code = clamped
                        }
                    }
            }
        }
        .onTapGesture {
            if isKeyboardDriven { isFocused = true }
        }
        .onAppear {
            if isKeyboardDriven { isFocused = true }
        }
    }

    @ViewBuilder
    private func box(at index: Int) -> some View {
        let isActiveBox = isKeyboardDriven
            ? (isFocused && index == code.count)
            : (index == code.count)
        let hasDigit = index < code.count

        ZStack {
            if hasDigit {
                Text(digit(at: index))
                    .font(AppTypography.title)
                    .foregroundStyle(Color.appOnSurface)
            } else if isActiveBox {
                Rectangle()
                    .fill(Color.appOnSurface)
                    .frame(width: 2)
                    .padding(.vertical, AppSpacing.sm)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 66) 
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
        .shadow(
            color: isActiveBox ? Color.appOnSurface.opacity(0.35) : Color.black.opacity(0.06),
            radius: isActiveBox ? 8 : 4,
            x: 0,
            y: isActiveBox ? 0 : 2
        )
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                .strokeBorder(
                    isActiveBox ? Color.appOnSurface : Color.appOnSurface.opacity(0.2),
                    lineWidth: isActiveBox ? 2 : 1
                )
        }
    }

    private func digit(at index: Int) -> String {
        guard index < code.count else { return "" }
        let charIndex = code.index(code.startIndex, offsetBy: index)
        return String(code[charIndex])
    }
}
