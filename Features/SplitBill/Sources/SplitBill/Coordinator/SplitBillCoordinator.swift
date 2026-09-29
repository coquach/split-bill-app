//
//  SplitBillCoordinator.swift
//  SplitBill
//
//  Created by Dinh Long on 28/9/26.
//

import Domains
import Router
import SwiftUI


public enum SplitBillEntry: Hashable {
    // From home tab
    case create(SplitSource)
    // From split history to split details
    case history
}

public enum SplitBillDestination: Hashable {
    case qr(SplitQRContext)
    case details(UUID)
    case edit(splitBillId: UUID, source: SplitSource, participantCount: Int)
}

public struct SplitBillCoordinator: View {
    @State private var router = Router()
    private let entry: SplitBillEntry
    private let dependencies: Dependencies
    private let onFinish: () -> Void

    public init(
        entry: SplitBillEntry,
        dependencies: Dependencies,
        onFinish: @escaping () -> Void
    ) {
        self.entry = entry
        self.dependencies = dependencies
        self.onFinish = onFinish
    }

    public var body: some View {
        NavigationStack(path: $router.navPath) {
            root
                .navigationDestination(for: SplitBillDestination.self) { destination in
                    switch destination {
                    case .qr(let context):
                        qrView(context)

                    case .details(let id):
                        detailsView(id)

                    case .edit(let id, let source, let participantCount):
                        setupView(
                            source: source,
                            editingSplitBillId: id,
                            participantCount: participantCount,
                            onBack: { router.navigateBack() }
                        )
                    }
                }
        }
        .environment(router)
    }

    @ViewBuilder
    private var root: some View {
        switch entry {
        case .create(let source):
            setupView(
                source: source,
                editingSplitBillId: nil,
                participantCount: 2,
                onBack: onFinish
            )

        case .history:
            SplitHistoryView(
                viewModel: SplitHistoryViewModel(
                    splitBillRepository: dependencies.splitBillRepository
                ),
                onBack: onFinish,
                onSelect: { bill in
                    router.navigate(to: SplitBillDestination.details(bill.id))
                }
            )
        }
    }

    private func setupView(
        source: SplitSource,
        editingSplitBillId: UUID?,
        participantCount: Int,
        onBack: @escaping () -> Void
    ) -> some View {
        SplitSetupView(
            viewModel: SplitSetupViewModel(
                source: source,
                splitBillRepository: dependencies.splitBillRepository,
                splitQRRepository: dependencies.splitQRRepository,
                editingSplitBillId: editingSplitBillId,
                participantCount: participantCount
            ),
            onBack: onBack,
            onGenerated: { context in
                router.navigate(to: SplitBillDestination.qr(context))
            }
        )
    }

    private func qrView(_ context: SplitQRContext) -> some View {
        SplitQRView(
            viewModel: SplitQRViewModel(context: context),
            onBack: { router.navigateBack() },
            onDone: onFinish
        )
    }

    private func detailsView(_ id: UUID) -> some View {
        SplitDetailsView(
            viewModel: SplitDetailsViewModel(
                splitBillId: id,
                splitBillRepository: dependencies.splitBillRepository,
                repaymentRepository: dependencies.repaymentRepository
            ),
            onBack: { router.navigateBack() },
            onDownloadQR: { splitBillId in
                Task {
                    if let context = await loadQRContext(splitBillId) {
                        router.navigate(to: SplitBillDestination.qr(context))
                    }
                }
            },
            onEdit: { detail in
                router.navigate(
                    to: SplitBillDestination.edit(
                        splitBillId: detail.splitBill.id,
                        source: source(from: detail),
                        participantCount: detail.splitBill.participantCount
                    )
                )
            }
        )
        // Pins its own bottom bar, which the tab bar would sit on top of.
        .toolbar(.hidden, for: .tabBar)
    }


    private func loadQRContext(_ splitBillId: UUID) async -> SplitQRContext? {
        do {
            let bill = try await dependencies.splitBillRepository
                .getSplitBillDetail(id: splitBillId)
            let qr = try await dependencies.splitQRRepository
                .getQR(splitBillId: splitBillId)

            return SplitQRContext(
                splitBillId: splitBillId,
                title: bill.splitBill.title,
                counterpartyName: bill.splitBill.title,
                participantCount: bill.splitBill.participantCount,
                perPersonAmount: bill.splitBill.perPersonAmount,
                qrPayload: qr.qrPayload
            )
        } catch {
            return nil
        }
    }

    private func source(from detail: SplitBillDetail) -> SplitSource {
        SplitSource(
            transferId: detail.splitBill.sourceTransferId,
            title: detail.splitBill.title,
            counterpartyName: detail.splitBill.title,
            date: detail.splitBill.createdAt,
            totalAmount: detail.splitBill.totalAmount
        )
    }
}

extension SplitBillCoordinator {
    public struct Dependencies {
        let splitBillRepository: ISplitBillRepository
        let splitQRRepository: ISplitQRRepository
        let repaymentRepository: IRepaymentRepository

        public init(
            splitBillRepository: ISplitBillRepository,
            splitQRRepository: ISplitQRRepository,
            repaymentRepository: IRepaymentRepository
        ) {
            self.splitBillRepository = splitBillRepository
            self.splitQRRepository = splitQRRepository
            self.repaymentRepository = repaymentRepository
        }
    }
}
