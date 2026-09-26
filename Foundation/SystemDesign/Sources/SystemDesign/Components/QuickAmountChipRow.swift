import SwiftUI

/// A horizontally scrollable row of quick-pick amount chips (e.g. 50K,
/// 100K, 500K) shown under the amount field on TransferInput.
public struct QuickAmountChipRow: View {
    private let amounts: [Int]
    private let onSelect: (Int) -> Void

    public init(amounts: [Int], onSelect: @escaping (Int) -> Void) {
        self.amounts = amounts
        self.onSelect = onSelect
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                ForEach(amounts, id: \.self) { amount in
                    Button {
                        onSelect(amount)
                    } label: {
                        Text(formatted(amount))
                            .font(AppTypography.label)
                            .foregroundStyle(Color.appOnSurface)
                            .padding(.horizontal, AppSpacing.md)
                            .padding(.vertical, AppSpacing.xs)
                            .background(Color.appSurface)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }

    // 500_000 -> "500K", 2_000_000 -> "2M"
    private func formatted(_ amount: Int) -> String {
        if amount >= 1_000_000 {
            return "\(amount / 1_000_000)M"
        } else if amount >= 1_000 {
            return "\(amount / 1_000)K"
        }
        return "\(amount)"
    }
}
