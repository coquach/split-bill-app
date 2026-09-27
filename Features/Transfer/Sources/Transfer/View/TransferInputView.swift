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
    private let onContinue: (TransferDraft) -> Void

    public init(viewModel: TransferInputViewModel, onContinue: @escaping (TransferDraft) -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onContinue = onContinue
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {

                // MARK: Receiver account number

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Receiver Account Number")
                        .font(AppTypography.label)
                        .foregroundStyle(Color.appOnSurface.opacity(0.6))

                    AppIconTextField(
                        icon: "creditcard",
                        placeholder: "0071 4482 7390",
                        text: $viewModel.accountNumber
                    )
                    .keyboardType(.numberPad)

                    lookupFeedback
                }

                // MARK: Amount

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Amount")
                        .font(AppTypography.label)
                        .foregroundStyle(Color.appOnSurface.opacity(0.6))

                    AmountField(amountText: $viewModel.amountText)

                    QuickAmountChipRow(
                        amounts: [500_000, 1_000_000, 2_000_000],
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

                // MARK: Description

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    HStack(spacing: AppSpacing.xxs) {
                        Text("Description")
                            .font(AppTypography.label)
                            .foregroundStyle(Color.appOnSurface.opacity(0.6))
                        Text("· optional")
                            .font(AppTypography.caption)
                            .foregroundStyle(Color.appOnSurface.opacity(0.4))
                    }

                    AppMultilineTextField(placeholder: "Add a note", text: $viewModel.descriptionText)
                }

                AppButton(title: "Continue", style: .primary) {
                    if let draft = viewModel.makeDraft() {
                        onContinue(draft)
                    }
                }
                .disabled(!viewModel.isFormValid)
                .opacity(viewModel.isFormValid ? 1 : 0.5)
            }
            .padding(AppSpacing.lg)
        }
        .background(Color.appBackground)
        .navigationTitle("Transfer")
        .navigationBarTitleDisplayMode(.inline)
    }

    // The green-check/red-mark convention: purely driven by lookup state,
    // no separate "verified" flag.
    @ViewBuilder
    private var lookupFeedback: some View {
        switch viewModel.lookupState {
        case .idle:
            EmptyView()

        case .loading:
            HStack(spacing: AppSpacing.xs) {
                ProgressView()
                Text("Looking up account…")
                    .font(AppTypography.caption)
                    .foregroundStyle(Color.appOnSurface.opacity(0.6))
            }

        case .found(let account):
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.appSuccess)
                Text(account.holderName)
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(Color.appOnSurface)
            }

        case .notFound:
            AlertBanner(message: "No account found with this number.", style: .error)

        case .failed(let message):
            AlertBanner(message: message, style: .error)
        }
    }
}
