//
//  PinView.swift
//  Profile
//
//  Created by Co Quach on 28/9/26.
//

import SwiftUI
import SystemDesign

// First-time setup: enter a new PIN, then enter it again to confirm.
public struct PinSetupView: View {
    let onSubmit: (String) async -> Bool

    public var body: some View {
        PinFlowView(
            requiresCurrentPin: false,
            onVerifyCurrent: { _ in true },
            onSubmit: { _, newPin in await onSubmit(newPin) }
        )
    }
}

// Change PIN: enter the current PIN, then a new PIN, then the new PIN again.
public struct ChangePinView: View {
    let onVerifyCurrent: (String) async -> Bool
    let onSubmit: (String, String) async -> Bool

    public var body: some View {
        PinFlowView(
            requiresCurrentPin: true,
            onVerifyCurrent: onVerifyCurrent,
            onSubmit: onSubmit
        )
    }
}

// One screen that walks through the PIN steps, using the same PIN boxes as the transfer PIN screen.
private struct PinFlowView: View {
    private enum Step {
        case current
        case new
        case confirm
    }

    @Environment(\.dismiss) private var dismiss

    let requiresCurrentPin: Bool
    let onVerifyCurrent: (String) async -> Bool
    let onSubmit: (String, String) async -> Bool

    @State private var step: Step
    // What the user is typing right now; moved into currentPin/newPin when they continue.
    @State private var entry = ""
    @State private var currentPin = ""
    @State private var newPin = ""
    @State private var isWorking = false
    @State private var errorMessage: String?

    private let pinLength = 6

    init(
        requiresCurrentPin: Bool,
        onVerifyCurrent: @escaping (String) async -> Bool,
        onSubmit: @escaping (String, String) async -> Bool
    ) {
        self.requiresCurrentPin = requiresCurrentPin
        self.onVerifyCurrent = onVerifyCurrent
        self.onSubmit = onSubmit
        _step = State(initialValue: requiresCurrentPin ? .current : .new)
    }

    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            iconBadge

            VStack(spacing: AppSpacing.xs) {
                Text(title)
                    .font(AppTypography.title)
                    .foregroundStyle(Color.appOnSurface)
                Text(subtitle)
                    .font(AppTypography.caption)
                    .foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.center)
            }

            OTPCodeInput(length: pinLength, code: $entry)
                .frame(maxWidth: 340)
                .frame(maxWidth: .infinity)

            if let errorMessage {
                AlertBanner(message: errorMessage, style: .error)
            }

            Spacer()
        }
        .padding(AppSpacing.lg)
        .padding(.top, AppSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.appBackground.ignoresSafeArea())
        .safeAreaInset(edge: .top, spacing: 0) {
            // A sheet has no top safe area, so add space to keep the bar off the edge
            AppNavBar(title: navTitle, onBack: goBack)
                .padding(.top, AppSpacing.lg)
                .background(Color.appBackground)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            BottomActionBar(
                primary: .init(
                    title: step == .confirm ? "Confirm" : "Continue",
                    style: .primary,
                    isEnabled: entry.count == pinLength,
                    isLoading: isWorking
                ) {
                    Task { await advance() }
                }
            )
        }
        .navigationBarHidden(true)
    }

    private var iconBadge: some View {
        Circle()
            .fill(Color.appIconBadge)
            .frame(width: 72, height: 72)
            .overlay {
                Image(systemName: "lock.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color.appOnSurface)
            }
    }

    private var navTitle: String {
        requiresCurrentPin ? "Change PIN" : "Set up PIN"
    }

    private var title: String {
        switch step {
        case .current: return "Enter Current PIN"
        case .new: return "Enter New PIN"
        case .confirm: return "Confirm New PIN"
        }
    }

    private var subtitle: String {
        switch step {
        case .current: return "Enter your current 6-digit PIN to continue"
        case .new: return "Choose a new 6-digit PIN to authorize your transactions"
        case .confirm: return "Enter the new PIN again to confirm"
        }
    }

    // Back steps to the previous PIN entry; on the first step it closes the screen.
    private func goBack() {
        errorMessage = nil
        entry = ""

        switch step {
        case .current:
            dismiss()
        case .new:
            if requiresCurrentPin {
                step = .current
            } else {
                dismiss()
            }
        case .confirm:
            step = .new
        }
    }

    private func advance() async {
        errorMessage = nil

        switch step {
        case .current:
            isWorking = true
            let isCorrect = await onVerifyCurrent(entry)
            isWorking = false

            guard isCorrect else {
                errorMessage = "Current PIN is incorrect."
                entry = ""
                return
            }
            currentPin = entry
            entry = ""
            step = .new

        case .new:
            if requiresCurrentPin && entry == currentPin {
                errorMessage = "New PIN must be different from your current PIN."
                entry = ""
                return
            }
            newPin = entry
            entry = ""
            step = .confirm

        case .confirm:
            guard entry == newPin else {
                errorMessage = "PINs don't match. Try again."
                entry = ""
                return
            }

            isWorking = true
            let didSucceed = await onSubmit(currentPin, newPin)
            isWorking = false

            if didSucceed {
                dismiss()
            } else {
                errorMessage = "Unable to save your PIN. Please try again."
                entry = ""
            }
        }
    }
}
