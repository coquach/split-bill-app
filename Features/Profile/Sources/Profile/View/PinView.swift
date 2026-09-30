//
//  PinView.swift
//  Profile
//
//  Created by Co Quach on 28/9/26.
//

import SwiftUI
import SystemDesign

public struct PinSetupView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var pin = ""
    @State private var confirmation = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    let onSubmit: (String) async -> Bool

    public var body: some View {
        Form {
            Section {
                SecureField("6-digit PIN", text: $pin)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .accessibilityIdentifier(UITestID.profilePinField)

                SecureField("Confirm PIN", text: $confirmation)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .accessibilityIdentifier(UITestID.profilePinField)
            } header: {
                Text("Transaction PIN")
            } footer: {
                Text("Use exactly 6 digits. This PIN is used to authorize protected transactions.")
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(Color.appError)
                }
            }

            Section {
                Button {
                    Task { await submit() }
                } label: {
                    HStack {
                        Spacer()
                        if isSubmitting {
                            ProgressView()
                        } else {
                            Text("Set PIN")
                                .font(AppTypography.bodyMedium)
                        }
                        Spacer()
                    }
                }
                .disabled(isSubmitting)
                .accessibilityIdentifier(UITestID.profilePinSubmit)
            }
        }
        .navigationTitle("Set up PIN")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }

    private func submit() async {
        let normalizedPin = pin.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedConfirmation = confirmation.trimmingCharacters(in: .whitespacesAndNewlines)

        guard normalizedPin.count == 6,
              normalizedPin.allSatisfy(\.isNumber) else {
            errorMessage = "PIN must be exactly 6 digits."
            return
        }

        guard normalizedPin == normalizedConfirmation else {
            errorMessage = "PIN confirmation does not match."
            return
        }

        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }

        if await onSubmit(normalizedPin) {
            dismiss()
        } else {
            errorMessage = "Unable to set up PIN. Please try again."
        }
    }
}

public struct ChangePinView: View {

    @Environment(\.dismiss)
    private var dismiss

    @State private var currentPin = ""
    @State private var newPin = ""
    @State private var confirmation = ""

    @State private var isSubmitting = false
    @State private var errorMessage: String?

    let onSubmit: (
        String,
        String
    ) async -> Bool

    public var body: some View {
        Form {
            Section("Current PIN") {
                SecureField(
                    "6-digit PIN",
                    text: $currentPin
                )
                .keyboardType(.numberPad)
                .accessibilityIdentifier(UITestID.profilePinField)
            }

            Section("New PIN") {
                SecureField(
                    "New PIN",
                    text: $newPin
                )
                .keyboardType(.numberPad)
                .accessibilityIdentifier(UITestID.profilePinField)

                SecureField(
                    "Confirm new PIN",
                    text: $confirmation
                )
                .keyboardType(.numberPad)
                .accessibilityIdentifier(UITestID.profilePinField)
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(Color.appError)
                }
            }

            Section {
                Button {
                    Task {
                        await submit()
                    }
                } label: {
                    HStack {
                        Spacer()

                        if isSubmitting {
                            ProgressView()
                        } else {
                            Text("Change PIN")
                        }

                        Spacer()
                    }
                }
                .disabled(isSubmitting)
                .accessibilityIdentifier(UITestID.profilePinSubmit)
            }
        }
        .navigationTitle("Change PIN")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(
                placement: .topBarLeading
            ) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }

    private func submit() async {
        guard currentPin.count == 6,
              currentPin.allSatisfy(\.isNumber)
        else {
            errorMessage = "Current PIN must be exactly 6 digits."
            return
        }

        guard newPin.count == 6,
              newPin.allSatisfy(\.isNumber)
        else {
            errorMessage = "New PIN must be exactly 6 digits."
            return
        }

        guard newPin == confirmation else {
            errorMessage = "PIN confirmation does not match."
            return
        }

        guard currentPin != newPin else {
            errorMessage = "New PIN must be different from current PIN."
            return
        }

        isSubmitting = true
        errorMessage = nil

        defer {
            isSubmitting = false
        }

        let success = await onSubmit(
            currentPin,
            newPin
        )

        if success {
            dismiss()
        } else {
            errorMessage = "Unable to change PIN."
        }
    }
}
