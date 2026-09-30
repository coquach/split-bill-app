//
//  TransferInputView.swift
//  Transfer
//
//  Created by Dinh Long on 26/9/26.
//

import Domains
import SwiftUI
import SystemDesign

public struct TransferInputView: View {
    @State private var viewModel: TransferFlowViewModel
    private let onBack: () -> Void
    private let onContinue: () -> Void

    public init(
        viewModel: TransferFlowViewModel,
        onBack: @escaping () -> Void,
        onContinue: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onBack = onBack
        self.onContinue = onContinue
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                receiverSection
                amountSection
                descriptionSection
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.lg)
            .padding(.bottom, AppSpacing.xxl)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .safeAreaInset(edge: .top, spacing: 0) {
            AppNavBar(title: "Transfer", onBack: onBack)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            BottomActionBar(
                primary: .init(
                    title: "Continue",
                    style: .primary,
                    isEnabled: viewModel.isFormValid,
                    accessibilityID: UITestID.transferContinue
                ) {
                    if viewModel.confirmInput() {
                        onContinue()
                    }
                }
            )
        }
        .navigationBarHidden(true)
        .screenLifecycle("TransferInput", onDisappear: viewModel.cancelPendingLookup)
    }

    private var receiverSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Receiver account number")
                .font(AppTypography.caption)
                .foregroundStyle(Color.appSecondary)

            AppIconTextField(
                icon: "creditcard",
                placeholder: "SP-1D533AB6FC",
                text: $viewModel.accountNumber,
                accessibilityID: UITestID.transferReceiverField
            )
            .keyboardType(.asciiCapable)
            .textInputAutocapitalization(.characters)
            .autocorrectionDisabled()

            resolvedReceiverRow
        }
    }

    @ViewBuilder
    private var resolvedReceiverRow: some View {
        switch viewModel.lookupState {
        case .idle:
            EmptyView()

        case .loading:
            HStack(spacing: AppSpacing.xs) {
                ProgressView()
                Text("Looking up account…")
                    .font(AppTypography.caption)
                    .foregroundStyle(Color.appSecondary)
            }

        case .found(let account):
            HStack(spacing: AppSpacing.xs) {
                Avatar(name: account.holderName, size: .small)
                Text(account.holderName)
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(Color.appOnSurface)
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.appSuccess)
            }
            .transition(.opacity)

        case .notFound:
            AlertBanner(message: "No account found with this number.", style: .error)

        case .failed(let message):
            AlertBanner(message: message, style: .error)
        }
    }

    private var amountSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Amount")
                .font(AppTypography.caption)
                .foregroundStyle(Color.appSecondary)

            AmountField(
                amountText: $viewModel.amountText,
                accessibilityID: UITestID.transferAmountField
            )

            balancePill
                .frame(maxWidth: .infinity, alignment: .center)

            QuickAmountChipRow(
                amounts: [500_000, 1_000_000, 2_000_000, 5_000_000],
                selectedAmount: Int(viewModel.amountText),
                accessibilityIDPrefix: "transfer.chip",
                onSelect: viewModel.selectQuickAmount
            )

            if let balance = viewModel.availableBalance,
               viewModel.exceedsAvailableBalance {
                // Plain red text, only while the amount is actually over the balance
                Text("This exceeds your available balance of \(balance.formatted) VND.")
                    .font(AppTypography.caption)
                    .foregroundStyle(Color.appError)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
            }
        }
    }

 
    @ViewBuilder
    private var balancePill: some View {
        if let balance = viewModel.availableBalance {
            pill(
                text: "Available balance \(balance.formatted) VND",
                foreground: Color.appInfo,
                background: Color.appInfoContainer
            )
        } else {
            pill(
                text: "Balance unavailable",
                foreground: Color.appTextTertiary,
                background: Color.appSurfaceSecondary
            )
        }
    }

    private func pill(
        text: String,
        foreground: Color,
        background: Color
    ) -> some View {
        Text(text)
            .font(AppTypography.label)
            .foregroundStyle(foreground)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.xs)
            .background(background)
            .clipShape(Capsule())
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack(spacing: AppSpacing.xxs) {
                Text("Description")
                Text("(optional)")
            }
            .font(AppTypography.caption)
            .foregroundStyle(Color.appSecondary)

            AppMultilineTextField(
                placeholder: "Add a note",
                text: $viewModel.descriptionText,
                accessibilityID: UITestID.transferNoteField
            )
        }
    }
}
