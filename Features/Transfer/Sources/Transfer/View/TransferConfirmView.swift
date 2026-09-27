//
//  TransferConfirmView.swift
//  Transfer
//
//  Created by Dinh Long on 26/9/26.
//

import SwiftUI
import SystemDesign

public struct TransferConfirmView: View {
    @State private var viewModel: TransferConfirmViewModel
    private let onConfirm: () -> Void
    private let onCancel: () -> Void

    public init(
        viewModel: TransferConfirmViewModel,
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
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
                            Text(viewModel.draft.amount.formatted)
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
                            Text(viewModel.draft.receiverHolderName)
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
                        Text(viewModel.draft.description.isEmpty ? "—" : viewModel.draft.description)
                    }
                }
            }

            AlertBanner(
                message: "Check the receiver details. Transfers cannot be reversed once sent.",
                style: .error
            )

            VStack(spacing: AppSpacing.sm) {
                AppButton(title: "Confirm & Send", style: .primary, action: onConfirm)
                AppButton(title: "Cancel", style: .secondary, action: onCancel)
            }
        }
        .padding(AppSpacing.lg)
        .background(Color.appBackground)
        .navigationTitle("Confirm Transfer")
        .navigationBarTitleDisplayMode(.inline)
        .screenLifecycle("TransferConfirm")
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
