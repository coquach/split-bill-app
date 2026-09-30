//
//  TransferConfirmView.swift
//  Transfer
//
//  Created by Dinh Long on 26/9/26.
//

import Domains
import SwiftUI
import SystemDesign

public struct TransferConfirmView: View {
    @State private var viewModel: TransferFlowViewModel
    private let onBack: () -> Void
    private let onConfirm: () -> Void
    private let onCancel: () -> Void

    public init(
        viewModel: TransferFlowViewModel,
        onBack: @escaping () -> Void,
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onBack = onBack
        self.onConfirm = onConfirm
        self.onCancel = onCancel
    }

    public var body: some View {
        VStack(spacing: AppSpacing.lg) {
            InfoCard {
                VStack(spacing: AppSpacing.md) {
                    VStack(spacing: AppSpacing.xxs) {
                        Text("YOU ARE SENDING")
                            .font(AppTypography.label)
                            .foregroundStyle(Color.appOnSurface.opacity(0.5))

                        HStack(alignment: .firstTextBaseline, spacing: AppSpacing.xxs) {
                            Text(draft.amount.formatted)
                                .font(AppTypography.display)
                            Text("VND")
                                .font(AppTypography.bodyMedium)
                                .foregroundStyle(Color.appOnSurface.opacity(0.6))
                        }
                    }
                    .frame(maxWidth: .infinity)

                    Divider()

                    row(label: "Receiver") {
                        VStack(alignment: .trailing, spacing: AppSpacing.xxs) {
                            Text(draft.receiverHolderName)
                            Text(viewModel.maskedAccountNumber)
                                .font(AppTypography.caption)
                                .foregroundStyle(Color.appOnSurface.opacity(0.5))
                        }
                    }

                    Divider()

                    row(label: "Bank") {
                        Text("SplitPay Wallet")
                    }

                    Divider()

                    row(label: "Description") {
                        Text(draft.description.isEmpty ? "—" : draft.description)
                    }
                }
            }

            AlertBanner(
                message: "Check the receiver details. Transfers cannot be reversed once sent.",
                style: .error
            )
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.appBackground.ignoresSafeArea())
        .safeAreaInset(edge: .top, spacing: 0) {
            AppNavBar(title: "Confirm Transfer", onBack: onBack)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            BottomActionBar(
                primary: .init(
                    title: "Confirm & Send",
                    style: .primary,
                    accessibilityID: UITestID.transferConfirm,
                    handler: onConfirm
                ),
                secondary: .init(
                    title: "Cancel",
                    style: .accent,
                    handler: onCancel
                )
            )
        }
        .navigationBarHidden(true)
        .screenLifecycle("TransferConfirm")
    }

    // Confirm is only ever pushed right after TransferFlowViewModel.confirmInput()
    // stores a draft, so it's always set by the time this screen appears.
    private var draft: TransferDraft {
        viewModel.draft!
    }

    @ViewBuilder
    private func row<Value: View>(label: String, @ViewBuilder value: () -> Value) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(AppTypography.body)
                .foregroundStyle(Color.appOnSurface.opacity(0.6))
            Spacer()
            value()
                .font(AppTypography.bodyMedium)
                .foregroundStyle(Color.appOnSurface)
                .multilineTextAlignment(.trailing)
        }
    }
}
