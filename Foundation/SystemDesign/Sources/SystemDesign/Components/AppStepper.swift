import SwiftUI

/// A minus/value/plus control for adjusting a count — e.g. number of
/// participants on SplitSetup.
public struct AppStepper: View {
    @Binding private var value: Int
    private let range: ClosedRange<Int>

    public init(value: Binding<Int>, range: ClosedRange<Int> = 1...20) {
        self._value = value
        self.range = range
    }

    public var body: some View {
        HStack(spacing: AppSpacing.md) {
            Button {
                value = max(range.lowerBound, value - 1)
            } label: {
                Image(systemName: "minus")
                    .foregroundStyle(Color.appOnSurface)
                    .frame(width: 32, height: 32)
                    .background(Color.appSurface)
                    .clipShape(Circle())
            }
            .disabled(value <= range.lowerBound)

            Text("\(value)")
                .font(AppTypography.bodyMedium)
                .foregroundStyle(Color.appOnSurface)
                .frame(minWidth: 24)

            Button {
                value = min(range.upperBound, value + 1)
            } label: {
                Image(systemName: "plus")
                    .foregroundStyle(Color.appOnSurface)
                    .frame(width: 32, height: 32)
                    .background(Color.appSurface)
                    .clipShape(Circle())
            }
            .disabled(value >= range.upperBound)
        }
    }
}
