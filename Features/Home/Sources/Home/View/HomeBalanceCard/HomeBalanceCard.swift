//
//  HomeBalanceCard.swift
//  Home
//
//  Created by Co Quach on 27/9/26.
//

import SwiftUI
import SystemDesign

struct HomeBalanceCard: View {

    let balance: String
    let currency: String
    let lastFourDigits: String
    let holderName: String

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 0
        ) {

            topRow

            Spacer(minLength: AppSpacing.xxl)

            balanceAmount

            Spacer(minLength: AppSpacing.xxl)

            bottomRow
        }
        .padding(AppSpacing.xl)
        .frame(
            maxWidth: .infinity,
            minHeight: 200
        )
        .background(background)
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppRadius.xl,
                style: .continuous
            )
        )
        .overlay {
            decorations
        }
        .shadow(
            color: Color.appPrimary.opacity(0.18),
            radius: 18,
            x: 0,
            y: 8
        )
    }

    private var topRow: some View {
        HStack {
            Text("AVAILABLE BALANCE")
                .font(
                    .system(
                        size: 11,
                        weight: .bold
                    )
                )
                .tracking(0.55)
                .foregroundStyle(
                    Color.appTextOnPrimary.opacity(0.82)
                )

            Spacer()

            Text("SPLITPAY")
                .font(
                    .system(
                        size: 11,
                        weight: .bold
                    )
                )
                .tracking(0.55)
                .foregroundStyle(Color.appTextOnPrimary)
                .padding(
                    .horizontal,
                    AppSpacing.sm
                )
                .padding(
                    .vertical,
                    AppSpacing.xxs
                )
                .background(
                    Color.appTextOnPrimary.opacity(0.16)
                )
                .clipShape(Capsule())
        }
    }

    private var balanceAmount: some View {
        HStack(
            alignment: .lastTextBaseline,
            spacing: AppSpacing.xs
        ) {
            Text(balance)
                .font(
                    .system(
                        size: 30,
                        weight: .bold
                    )
                )
                .tracking(-0.7)
                .foregroundStyle(Color.appTextOnPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.55)
                .accessibilityIdentifier(UITestID.homeBalance)

            Text(currency)
                .font(
                    .system(
                        size: 20,
                        weight: .bold
                    )
                )
                .foregroundStyle(
                    Color.appTextOnPrimary.opacity(0.78)
                )
        }
    }

    private var bottomRow: some View {
        HStack {
            HStack(spacing: AppSpacing.xs) {
                Text("•••• ••••")
                    .font(
                        .system(
                            size: 14,
                            weight: .regular,
                            design: .monospaced
                        )
                    )
                    .foregroundStyle(
                        Color.appTextOnPrimary.opacity(0.7)
                    )

                Text(lastFourDigits)
                    .font(
                        .system(
                            size: 14,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(Color.appTextOnPrimary)
            }

            Spacer()

            Text(holderName)
                .font(.system(size: 12))
                .foregroundStyle(
                    Color.appTextOnPrimary.opacity(0.88)
                )
                .lineLimit(1)
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [
                Color.appPrimary,
                Color.appPrimary.opacity(0.88),
                Color.appSecondary
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var decorations: some View {
        ZStack {
            Circle()
                .fill(
                    Color.appTextOnPrimary.opacity(0.06)
                )
                .frame(
                    width: 256,
                    height: 256
                )
                .offset(
                    x: 110,
                    y: -80
                )

            Circle()
                .fill(
                    Color.appTextOnPrimary.opacity(0.05)
                )
                .frame(
                    width: 224,
                    height: 224
                )
                .offset(
                    x: 100,
                    y: 70
                )
        }
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppRadius.xl,
                style: .continuous
            )
        )
        .allowsHitTesting(false)
    }
}
