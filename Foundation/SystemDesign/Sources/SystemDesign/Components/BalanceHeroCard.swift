//
//  BalanceHeroCard.swift
//  SystemDesign
//
//  Created by Dinh Long on 26/9/26.
//


import SwiftUI

public struct BalanceHeroCard: View {
    private let holderName: String
    private let accountNumber: String
    private let balanceText: String   // pre-formatted, e.g. "12,450,000 VND"

    @Binding private var isBalanceHidden: Bool

    public init(
        holderName: String,
        accountNumber: String,
        balanceText: String,
        isBalanceHidden: Binding<Bool>
    ) {
        self.holderName = holderName
        self.accountNumber = accountNumber
        self.balanceText = balanceText
        self._isBalanceHidden = isBalanceHidden
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Hi, \(holderName)")
                .font(AppTypography.body)
                .foregroundStyle(.white.opacity(0.8))

            HStack(spacing: AppSpacing.xs) {
                Text(isBalanceHidden ? "••••••" : balanceText)
                    .font(AppTypography.display)
                    .foregroundStyle(.white)

                Button {
                    isBalanceHidden.toggle()
                } label: {
                    Image(systemName: isBalanceHidden ? "eye.slash.fill" : "eye.fill")
                        .foregroundStyle(.white.opacity(0.8))
                }
            }

            Text(accountNumber)
                .font(AppTypography.caption)
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.lg)
        .background(
            LinearGradient(
                colors: [Color.appPrimary, Color.appPrimaryContainer],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous))
    }
}
