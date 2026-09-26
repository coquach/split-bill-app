//
//  BalanceCard.swift
//  Home
//
//  Created by Co Quach on 18/9/26.
//

import SwiftUI
import SystemDesign

struct BalanceCard: View {

    let balance: String
    let lastFourDigits: String

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.md
        ) {
            HStack {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(
                            Color.appOnSurface
                        )
                        .frame(
                            width: 52,
                            height: 40
                        )
                        .background(
                            Color.white.opacity(0.85)
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 8,
                                style: .continuous
                            )
                        )

                    Image(systemName: "wave.3.right")
                        .font(.system(size: 22))
                        .foregroundStyle(
                            Color.white.opacity(0.55)
                        )
                }

                Spacer()

                Text("•••• \(lastFourDigits)")
                    .font(
                        .system(
                            size: 14,
                            weight: .semibold,
                            design: .monospaced
                        )
                    )
                    .foregroundStyle(
                        Color.white.opacity(0.75)
                    )
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        Color.white.opacity(0.12)
                    )
                    .clipShape(Capsule())
            }

            Spacer()

            Text("TOTAL ACTIVE BALANCE")
                .font(AppTypography.label)
                .foregroundStyle(
                    Color.white.opacity(0.62)
                )

            HStack(
                alignment: .lastTextBaseline,
                spacing: AppSpacing.sm
            ) {
                Text(balance)
                    .font(
                        .system(
                            size: 48,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .tracking(-1.5)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.55)
                    .allowsTightening(true)

                Text("VND")
                    .font(
                        .system(
                            size: 18,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(Color.appPrimaryContainer)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(32)
        .frame(
            maxWidth: .infinity,
            minHeight: 358
        )
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0.12, blue: 0.13),
                    Color.appPrimary.opacity(0.72),
                    Color(red: 0.10, green: 0.12, blue: 0.13)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppRadius.xl,
                style: .continuous
            )
        )
    }
}


#Preview {
    BalanceCard(balance: "214232", lastFourDigits: "4")
}
