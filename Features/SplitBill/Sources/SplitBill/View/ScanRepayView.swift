//
//  ScanRepayView.swift
//  SplitBill
//
//  Created by Dinh Long on 29/9/26.
//

import Domains
import SwiftUI
import SystemDesign

public struct ScanRepayView: View {
    @State private var viewModel: ScanRepayViewModel
    private let onBack: () -> Void
    private let onDecoded: (ScannedRepayment) -> Void
    // UI-test seam: when non-nil the camera is skipped entirely and this
    // payload is fed through the same decode path a real scan would take
    // (see SplitBillCoordinator.Dependencies).
    private let mockScanPayload: String?

    public init(
        viewModel: ScanRepayViewModel,
        mockScanPayload: String? = nil,
        onBack: @escaping () -> Void,
        onDecoded: @escaping (ScannedRepayment) -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.mockScanPayload = mockScanPayload
        self.onBack = onBack
        self.onDecoded = onDecoded
    }

    public var body: some View {
        ZStack {
            if let payload = mockScanPayload {
                // No camera in UI tests - a black stand-in that decodes after a short beat, like a real scan settling
                Color.black.ignoresSafeArea()
                    .task {
                        try? await Task.sleep(for: .milliseconds(300))
                        guard !Task.isCancelled else { return }
                        if let scanned = await viewModel.decode(payload) {
                            onDecoded(scanned)
                        }
                    }
            } else {
                QRScannerView(isFailed: viewModel.errorMessage != nil) { payload in
                    Task {
                        if let scanned = await viewModel.decode(payload) {
                            onDecoded(scanned)
                        }
                    }
                }
                .ignoresSafeArea()

                scanFrame
            }

            VStack {
                Spacer()

                if viewModel.state == .decoding {
                    ProgressView()
                        .tint(.white)
                        .padding(AppSpacing.lg)
                        .background(.black.opacity(0.6))
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
                        .padding(.bottom, AppSpacing.huge)
                } else {
                    Text("Point your camera at a Split Bill QR code")
                        .font(AppTypography.body)
                        .foregroundStyle(.white)
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.vertical, AppSpacing.sm)
                        .background(.black.opacity(0.6))
                        .clipShape(Capsule())
                        .padding(.bottom, AppSpacing.huge)
                }
            }

            VStack {
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "xmark")
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .accessibilityIdentifier(UITestID.scanClose)
                    .padding(AppSpacing.lg)

                    Spacer()
                }
                Spacer()
            }
        }
        .background(Color.black.ignoresSafeArea())
        .screenLifecycle("ScanRepay")
        .modalOverlay(isPresented: viewModel.errorMessage != nil) {
            AppModal(
                icon: Image(systemName: "exclamationmark.triangle.fill"),
                title: "Couldn't Read QR Code",
                message: viewModel.errorMessage ?? "Something went wrong.",
                accessibilityID: UITestID.errorModalTitle
            ) {
                AppButton(title: "Try Again", style: .primary, accessibilityID: UITestID.errorModalRetry) {
                    viewModel.retry()
                }
            }
        }
    }

    // Dims everything outside the square, then outlines the square that is actually scanned
    private var scanFrame: some View {
        let side = QRScannerView.scanAreaSize
        let shape = RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)

        return ZStack {
            Color.black.opacity(0.5)
                .mask {
                    // destinationOut punches a hole where the square is
                    Rectangle()
                        .overlay {
                            shape
                                .frame(width: side, height: side)
                                .blendMode(.destinationOut)
                        }
                        .compositingGroup()
                }

            shape
                .strokeBorder(Color.white, lineWidth: 3)
                .frame(width: side, height: side)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}
