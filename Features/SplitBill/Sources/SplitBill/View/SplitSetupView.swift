//
//  SplitSetupView.swift
//  SplitBill
//
//  Created by Dinh Long on 28/9/26.
//

import Domains
import SwiftUI
import SystemDesign

public struct SplitSetupView: View {
    @State private var viewModel: SplitFlowViewModel
    private let onBack: () -> Void
    private let onGenerated: () -> Void
    private let onCancelled: () -> Void

    public init(
        viewModel: SplitFlowViewModel,
        onBack: @escaping () -> Void,
        onGenerated: @escaping () -> Void,
        onCancelled: @escaping () -> Void = {}
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onBack = onBack
        self.onGenerated = onGenerated
        self.onCancelled = onCancelled
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                sourceCard
                participantRow
                calculationCard
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.lg)
            .padding(.bottom, AppSpacing.xxl)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .safeAreaInset(edge: .top, spacing: 0) {
            AppNavBar(title: "Split Bill", onBack: onBack)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            BottomActionBar(
                primary: .init(
                    title: viewModel.primaryActionTitle,
                    style: .primary,
                    icon: "qrcode",
                    isLoading: viewModel.isCreating,
                    accessibilityID: UITestID.splitCreate
                ) {
                    Task {
                        if await viewModel.generateQR() {
                            onGenerated()
                        }
                    }
                },
                secondary: viewModel.isEditing
                    ? .init(
                        title: "Cancel Split",
                        style: .destructive,
                        icon: "xmark.circle",
                        isEnabled: !viewModel.isCreating
                    ) {
                        viewModel.requestCancelConfirmation()
                    }
                    : nil
            )
        }
        .navigationBarHidden(true)
        .screenLifecycle("SplitSetup")
        .modalOverlay(isPresented: viewModel.errorMessage != nil) {
            AppModal(
                icon: Image(systemName: "exclamationmark.triangle.fill"),
                title: "Couldn't Create Split",
                message: viewModel.errorMessage ?? "Something went wrong.",
                accessibilityID: UITestID.errorModalTitle
            ) {
                AppButton(title: "Try Again", style: .primary, accessibilityID: UITestID.errorModalRetry) {
                    viewModel.dismissError()
                }
            }
        }
        .modalOverlay(isPresented: viewModel.isShowingCancelConfirmation) {
            AppModal(
                icon: Image(systemName: "exclamationmark.triangle.fill"),
                title: "Cancel This Split?",
                message: "The split will become inactive and no one will be able to pay it through the QR code anymore.",
                accessibilityID: UITestID.errorModalTitle
            ) {
                VStack(spacing: AppSpacing.sm) {
                    AppButton(
                        title: "Cancel Split",
                        style: .destructive,
                        isLoading: viewModel.isCancelling
                    ) {
                        Task {
                            if await viewModel.cancelSplit() {
                                onCancelled()
                            }
                        }
                    }
                    AppButton(title: "Keep Split", style: .secondary) {
                        viewModel.dismissCancelConfirmation()
                    }
                }
            }
        }
    }

    private var sourceCard: some View {
        HStack(spacing: AppSpacing.sm) {
            Circle()
                .fill(Color.appSurfaceSecondary)
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.appTextPrimary)
                }

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(viewModel.source.title)
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(Color.appTextPrimary)
                Text(viewModel.sourceSubtitle)
                    .font(AppTypography.caption)
                    .foregroundStyle(Color.appTextSecondary)
            }

            Spacer()

            Text(viewModel.source.totalAmount.formatted)
                .font(AppTypography.bodyMedium)
                .foregroundStyle(Color.appTextPrimary)
        }
        .padding(AppSpacing.md)
        .background(Color.appSurfacePrimary)
        .clipShape(
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .strokeBorder(Color.appBorderDefault, lineWidth: 1)
        }
    }

    private var participantRow: some View {
        HStack {
            Text("Number of Participants")
                .font(AppTypography.label)
                .foregroundStyle(Color.appTextPrimary)

            Spacer()

            AppStepper(
                value: $viewModel.participantCount,
                range: SplitFlowViewModel.participantRange,
                decrementID: UITestID.splitParticipantsMinus,
                incrementID: UITestID.splitParticipantsPlus
            )
        }
    }

    private var calculationCard: some View {
        VStack(spacing: AppSpacing.lg) {
            DividedInfoStack([
                .init(
                    label: "Total Amount",
                    value: "\(viewModel.source.totalAmount.formatted) VND"
                ),
                .init(
                    label: "Participant Count",
                    value: "\(viewModel.participantCount)"
                ),
            ])

            VStack(spacing: AppSpacing.xxs) {
                Text("Amount Per Person")
                    .font(AppTypography.caption)
                    .foregroundStyle(Color.appTextSecondary)

                Text(viewModel.amountPerPersonText)
                    .font(AppTypography.display)
                    .foregroundStyle(Color.appTextPrimary)
                
                Text(
                    viewModel.splitsEvenly
                        ? "Splits evenly"
                        : "You cover \(viewModel.requesterAmountText) VND"
                )
                .font(AppTypography.caption)
                .foregroundStyle(Color.appTextSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(AppSpacing.md)
        .background(Color.appSurfacePrimary)
        .clipShape(
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
        )
    }
}
