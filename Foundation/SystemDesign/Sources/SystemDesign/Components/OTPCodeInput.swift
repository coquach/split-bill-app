import SwiftUI

/// A row of boxed digits for entering an OTP code — used on the OTP
/// verification step before confirming a transfer.
public struct OTPCodeInput: View {
    private let length: Int
    @Binding private var code: String
    @FocusState private var isFocused: Bool

    public init(length: Int = 6, code: Binding<String>) {
        self.length = length
        self._code = code
    }

    public var body: some View {
        ZStack {
            HStack(spacing: AppSpacing.sm) {
                ForEach(0..<length, id: \.self) { index in
                    let isActiveBox = isFocused && index == code.count

                    Text(digit(at: index))
                        .font(AppTypography.title)
                        .foregroundStyle(Color.appOnSurface)
                        .frame(width: 44, height: 52)
                        .background(Color.appSurface)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                                .strokeBorder(isActiveBox ? Color.appPrimaryContainer : Color.clear, lineWidth: 2)
                        }
                }
            }

            // The boxes above are just a picture of the code. This invisible
            // field is what actually receives keyboard input — a common
            // trick since SwiftUI has no built-in "OTP box" input.
            TextField("", text: $code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode) // lets iOS offer to autofill an SMS code
                .foregroundStyle(.clear)
                .tint(.clear)
                .focused($isFocused)
                .onChange(of: code) { _, newValue in
                    if newValue.count > length {
                        code = String(newValue.prefix(length))
                    }
                }
        }
        .onTapGesture { isFocused = true }
    }

    private func digit(at index: Int) -> String {
        guard index < code.count else { return "" }
        let charIndex = code.index(code.startIndex, offsetBy: index)
        return String(code[charIndex])
    }
}
