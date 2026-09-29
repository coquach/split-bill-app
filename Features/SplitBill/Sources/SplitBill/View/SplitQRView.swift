//
//  SplitQRView.swift
//  SplitBill
//
//  Created by Dinh Long on 28/9/26.
//

import SwiftUI
import SystemDesign

public struct SplitQRView: View {
    @State private var viewModel: SplitQRViewModel
    private let onBack: () -> Void
    private let onDone: () -> Void

    public init(
        viewModel: SplitQRViewModel,
        onBack: @escaping () -> Void,
        onDone: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onBack = onBack
        self.onDone = onDone
    }

    public var body: some View {
        ScrollView {
            QRCard(
                data: viewModel.context.qrPayload,
                title: viewModel.context.title,
                subtitle: viewModel.subtitle,
                captionLabel: "Amount per person:",
                captionValue: viewModel.perPersonText
            )
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.lg)
            .padding(.bottom, AppSpacing.xxl)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .safeAreaInset(edge: .top, spacing: 0) {
            AppNavBar(title: "Split QR", onBack: onBack)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) { bottomActions }
        .navigationBarHidden(true)
        .screenLifecycle("SplitQR")
    }

    @ViewBuilder
    private var bottomActions: some View {
        if let image = viewModel.qrImage {
            VStack(spacing: 0) {
                BottomActionBar(
                    primary: .init(
                        title: "Share",
                        style: .primary,
                        icon: "square.and.arrow.up"
                    ) {
                        share(image)
                    },
                    secondary: .init(
                        title: "Save",
                        style: .secondary,
                        icon: "square.and.arrow.down"
                    ) {
                        save(image)
                    },
                    layout: .sideBySide,
                    link: .init(
                        title: "Home",
                        handler: onDone
                    )
                )
            }
        } else {
            BottomActionBar(
                primary: .init(title: "Done", style: .primary, handler: onDone)
            )
        }
    }

    private func save(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }

    private func share(_ image: UIImage) {
        guard
            let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive })
                as? UIWindowScene,
            let root = scene.keyWindow?.rootViewController
        else {
            return
        }

        let controller = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )

        // Required on iPad, where a share sheet is a popover and needs an
        // anchor; harmless on iPhone.
        controller.popoverPresentationController?.sourceView = root.view

        root.present(controller, animated: true)
    }
}
