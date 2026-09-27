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
    @State private var viewModel: TransferInputViewModel
    private let onBack: () -> Void
    private let onContinue: (TransferDraft) -> Void

    public init(
        viewModel: TransferInputViewModel,
        onBack: @escaping () -> Void,
        onContinue: @escaping (TransferDraft) -> Void
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
        .background(Color.appBackground)
        .safeAreaInset(edge: .top, spacing: 0) { topNavBar }
        .safeAreaInset(edge: .bottom, spacing: 0) { bottomBar }
        .navigationBarHidden(true)
        .screenLifecycle("TransferInput", onDisappear: viewModel.cancelPendingLookup)
    }

    // MARK: - Pinned top nav bar

    private var topNavBar: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .foregroundStyle(Color.appOnSurface)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)

            Spacer()

            Text("Transfer")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.appOnSurface)

            Spacer()

            // Balances the leading chevron so the title stays centered.
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, AppSpacing.xs)
        .frame(height: 44)
        .background(Color.appBackground)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.black.opacity(0.05))
                .frame(height: 1)
                .blur(radius: 2)
                .offset(y: 2)
        }
    }

    // MARK: - Receiver

    private var receiverSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Receiver account number")
                .font(AppTypography.caption)
                .foregroundStyle(Color.appSecondary)

            AppIconTextField(
                icon: "creditcard",
                placeholder: "0071 4482 7390",
                text: $viewModel.accountNumber
            )
            .keyboardType(.numberPad)

            resolvedReceiverRow
        }
    }

    // The green-check/red-mark convention: purely driven by lookup state,
    // no separate "verified" flag. Inline row under the field, not a
    // separate screen state or modal, so the user keeps context of what
    // they typed while seeing confirmation.
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

    // MARK: - Amount

    private var amountSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Amount")
                .font(AppTypography.caption)
                .foregroundStyle(Color.appSecondary)

            AmountField(amountText: $viewModel.amountText)

            balancePill
                .frame(maxWidth: .infinity, alignment: .center)

            QuickAmountChipRow(
                amounts: [500_000, 1_000_000, 2_000_000, 5_000_000],
                selectedAmount: Int(viewModel.amountText),
                onSelect: viewModel.selectQuickAmount
            )

            if viewModel.exceedsAvailableBalance {
                AlertBanner(
                    message: "This exceeds your available balance of \(viewModel.availableBalance.formatted) VND.",
                    style: .warning
                )
            }
        }
    }

    // A narrow, deliberate exception to the neutral+mint palette - an
    // "info pill" used only for this kind of informational call-out.
    private var balancePill: some View {
        Text("Available balance \(viewModel.availableBalance.formatted) VND")
            .font(AppTypography.label)
            .foregroundStyle(Color.appInfo)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.xs)
            .background(Color.appInfoContainer)
            .clipShape(Capsule())
    }

    // MARK: - Description

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack(spacing: AppSpacing.xxs) {
                Text("Description")
                Text("(optional)")
            }
            .font(AppTypography.caption)
            .foregroundStyle(Color.appSecondary)

            AppMultilineTextField(placeholder: "Add a note", text: $viewModel.descriptionText)
        }
    }

    // MARK: - Pinned bottom bar

    private var bottomBar: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.black.opacity(0.05))
                .frame(height: 1)
                .blur(radius: 2)
                .offset(y: -2)

            AppButton(title: "Continue", style: .primary) {
                if let draft = viewModel.makeDraft() {
                    onContinue(draft)
                }
            }
            .disabled(!viewModel.isFormValid)
            .opacity(viewModel.isFormValid ? 1 : 0.35)
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.sm)
        }
        .background(Color.appSurface)
    }
}
