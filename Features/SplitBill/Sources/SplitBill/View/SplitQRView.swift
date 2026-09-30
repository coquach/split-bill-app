//
//  SplitQRView.swift
//  SplitBill
//
//  Created by Dinh Long on 28/9/26.
//

import SwiftUI
import SystemDesign

public struct SplitQRView: View {
    @State private var viewModel: SplitFlowViewModel
    private let onBack: () -> Void
    private let onDone: () -> Void

    public init(
        viewModel: SplitFlowViewModel,
        onBack: @escaping () -> Void,
        onDone: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onBack = onBack
        self.onDone = onDone
    }

    // This screen is only ever reached once Setup's generateQR() (or the
    // Download QR path) has already stored a context on the shared VM.
    private var context: SplitQRContext {
        viewModel.context!
    }

    public var body: some View {
        ScrollView {
            QRCard(
                data: context.qrPayload,
                title: context.title,
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
                        title: "Save",
                        style: .primary,
                        icon: "square.and.arrow.down"
                    ) {
                        save(image)
                    },
                    secondary: .init(
                        title: "Home",
                        style: .secondary,
                        icon: "house.fill",
                        handler: onDone
                    ),
                    layout: .sideBySide
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
}
