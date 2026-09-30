//
//  SplitFlowViewModelTests.swift
//  SplitBillTests
//

import Domains
import Foundation
@testable import SplitBill
import Testing

@Suite("SplitFlowViewModel")
@MainActor
struct SplitFlowViewModelTests {
    private let splitBillRepository = MockSplitBillRepository()
    private let splitQRRepository = MockSplitQRRepository()

    private func makeViewModel(
        totalAmount: Amount = Amount(100),
        editingSplitBillId: UUID? = nil,
        participantCount: Int = 2
    ) -> SplitFlowViewModel {
        SplitFlowViewModel(
            source: makeSource(totalAmount: totalAmount),
            splitBillRepository: splitBillRepository,
            splitQRRepository: splitQRRepository,
            editingSplitBillId: editingSplitBillId,
            participantCount: participantCount
        )
    }

    // MARK: - Setup step

    @Test
    func theParticipantRangeSpansTwoToTen() {
        #expect(SplitFlowViewModel.participantRange == 2 ... 10)
    }

    @Test(arguments: [
        (2, Amount(50), Amount(50), true),
        (3, Amount(33.33), Amount(33.34), false),
        (4, Amount(25), Amount(25), true),
    ])
    func theSplitMathFollowsTheParticipantCount(
        _ participants: Int,
        _ perPerson: Amount,
        _ requester: Amount,
        _ evenly: Bool
    ) {
        let viewModel = makeViewModel(totalAmount: Amount(100), participantCount: participants)

        #expect(viewModel.amountPerPerson == perPerson)
        #expect(viewModel.requesterAmount == requester)
        #expect(viewModel.splitsEvenly == evenly)
    }

    @Test
    func thePrimaryActionReflectsTheEditingMode() {
        #expect(makeViewModel().primaryActionTitle == "Generate QR")
        #expect(makeViewModel(editingSplitBillId: UUID()).primaryActionTitle == "Update & Show QR")
        #expect(makeViewModel().isEditing == false)
        #expect(makeViewModel(editingSplitBillId: UUID()).isEditing == true)
    }

    @Test
    func dismissErrorIsANoopWhileIdle() {
        let viewModel = makeViewModel()

        viewModel.dismissError()

        #expect(viewModel.state == .idle)
        #expect(viewModel.errorMessage == nil)
    }

    @Test
    func theCancelConfirmationIsAPlainFlag() {
        let viewModel = makeViewModel()

        viewModel.requestCancelConfirmation()
        #expect(viewModel.isShowingCancelConfirmation == true)

        viewModel.dismissCancelConfirmation()
        #expect(viewModel.isShowingCancelConfirmation == false)
    }

    // MARK: - Generate QR (create path)

    @Test
    func generatingQRCreatesTheBillThenReadsItsQR() async {
        let bill = makeSplitBill(participantCount: 3, perPersonAmount: Amount(33.33))
        splitBillRepository.createdBill = bill
        splitQRRepository.qr = makeQRCode(splitBillId: bill.id, qrPayload: "payload-1")
        let viewModel = makeViewModel(totalAmount: Amount(100), participantCount: 3)

        let succeeded = await viewModel.generateQR()

        #expect(succeeded == true)
        #expect(viewModel.state == .idle)
        #expect(splitBillRepository.createSplitBillCalls == 1)
        #expect(splitBillRepository.lastCreateCommand?.title == "Team lunch")
        #expect(splitBillRepository.lastCreateCommand?.participantCount == 3)
        #expect(splitBillRepository.lastCreateCommand?.sourceTransferId == viewModel.source.transferId)
        #expect(splitBillRepository.lastCreateCommand?.expiryDays == 7)
        #expect(splitQRRepository.lastQRSplitBillId == bill.id)
        #expect(viewModel.context?.splitBillId == bill.id)
        #expect(viewModel.context?.qrPayload == "payload-1")
        #expect(viewModel.context?.counterpartyName == "Binh Tran")
        #expect(viewModel.context?.participantCount == 3)
        #expect(viewModel.context?.perPersonAmount == Amount(33.33))
    }

    @Test
    func aFailedCreateSurfacesTheErrorAndLeavesNoContext() async {
        splitBillRepository.error = DomainError.validation
        let viewModel = makeViewModel()

        let succeeded = await viewModel.generateQR()

        #expect(succeeded == false)
        #expect(viewModel.state == .failed(.validation))
        #expect(viewModel.context == nil)
        #expect(splitQRRepository.getQRCalls == 0)
    }

    @Test
    func aSecondGenerateWhileInFlightIsANoop() async throws {
        splitBillRepository.createdBill = makeSplitBill()
        splitQRRepository.qr = makeQRCode()
        splitBillRepository.holdCreateSplit = true
        let viewModel = makeViewModel()

        async let first = viewModel.generateQR()
        // Let the first call enter the creating state before the second.
        try await Task.sleep(for: .milliseconds(100))
        let second = await viewModel.generateQR()

        #expect(second == false)
        splitBillRepository.resumeCreateSplit()
        #expect(await first == true)
        #expect(splitBillRepository.createSplitBillCalls == 1)
    }

    // MARK: - Generate QR (update path)

    @Test
    func editingUpdatesTheExistingBillInsteadOfCreating() async {
        let editingId = UUID()
        let existing = makeSplitBill(id: editingId, title: "Original title", participantCount: 3)
        splitBillRepository.detail = makeDetail(splitBill: existing)
        splitBillRepository.updatedBill = makeSplitBill(id: editingId, participantCount: 4)
        splitQRRepository.qr = makeQRCode(splitBillId: editingId, qrPayload: "payload-2")
        let viewModel = makeViewModel(editingSplitBillId: editingId, participantCount: 4)

        let succeeded = await viewModel.generateQR()

        #expect(succeeded == true)
        #expect(splitBillRepository.createSplitBillCalls == 0)
        #expect(splitBillRepository.lastDetailId == editingId)
        // The update keeps the stored fields and only carries the new count.
        #expect(splitBillRepository.lastUpdateCommand?.splitBillId == editingId)
        #expect(splitBillRepository.lastUpdateCommand?.title == "Original title")
        #expect(splitBillRepository.lastUpdateCommand?.participantCount == 4)
        #expect(splitBillRepository.lastUpdateCommand?.expiresAt == existing.expiresAt)
        #expect(splitQRRepository.lastQRSplitBillId == editingId)
        #expect(viewModel.context?.splitBillId == editingId)
        #expect(viewModel.context?.participantCount == 4)
    }

    // MARK: - Cancel

    @Test
    func cancelWithoutAnEditingTargetIsRejectedUpFront() async {
        let viewModel = makeViewModel()

        let cancelled = await viewModel.cancelSplit()

        #expect(cancelled == false)
        #expect(splitBillRepository.closeSplitBillCalls == 0)
        #expect(viewModel.state == .idle)
    }

    @Test
    func aSuccessfulCancelClosesTheEditedBill() async {
        let editingId = UUID()
        splitBillRepository.closedBill = makeSplitBill(id: editingId, status: .cancelled)
        let viewModel = makeViewModel(editingSplitBillId: editingId)
        viewModel.requestCancelConfirmation()

        let cancelled = await viewModel.cancelSplit()

        #expect(cancelled == true)
        #expect(splitBillRepository.lastClosedId == editingId)
        #expect(viewModel.isShowingCancelConfirmation == false)
        #expect(viewModel.state == .idle)
    }

    @Test
    func aFailedCancelSurfacesTheError() async {
        splitBillRepository.error = DomainError.notFound
        let viewModel = makeViewModel(editingSplitBillId: UUID())
        viewModel.requestCancelConfirmation()

        let cancelled = await viewModel.cancelSplit()

        #expect(cancelled == false)
        #expect(viewModel.isShowingCancelConfirmation == false)
        #expect(viewModel.state == .failed(.notFound))
        #expect(viewModel.errorMessage != nil)
    }

    // MARK: - Resolved context

    @Test
    func aPreResolvedContextSkipsTheRoundTrip() {
        let context = SplitQRContext(
            splitBillId: UUID(),
            title: "Team lunch",
            counterpartyName: "Binh Tran",
            participantCount: 3,
            perPersonAmount: Amount(33.33),
            qrPayload: "payload-3"
        )
        let viewModel = makeViewModel()

        viewModel.setResolvedContext(context)

        #expect(viewModel.context == context)
        #expect(splitBillRepository.createSplitBillCalls == 0)
        #expect(splitBillRepository.updateSplitBillCalls == 0)
        #expect(splitQRRepository.getQRCalls == 0)
    }

    @Test
    func theSubtitlePluralizesByParticipantCount() {
        let single = SplitQRContext(
            splitBillId: UUID(),
            title: "Solo",
            counterpartyName: "Binh Tran",
            participantCount: 1,
            perPersonAmount: Amount(100),
            qrPayload: "p"
        )
        let group = SplitQRContext(
            splitBillId: UUID(),
            title: "Group",
            counterpartyName: "Binh Tran",
            participantCount: 3,
            perPersonAmount: Amount(33.33),
            qrPayload: "p"
        )
        let viewModel = makeViewModel()

        viewModel.setResolvedContext(single)
        #expect(viewModel.subtitle == "Binh Tran · 1 person")

        viewModel.setResolvedContext(group)
        #expect(viewModel.subtitle == "Binh Tran · 3 people")
    }

    @Test
    func perPersonTextIsRenderedWithTheCurrency() {
        let viewModel = makeViewModel()
        #expect(viewModel.perPersonText == "")

        viewModel.setResolvedContext(
            SplitQRContext(
                splitBillId: UUID(),
                title: "T",
                counterpartyName: "B",
                participantCount: 3,
                perPersonAmount: Amount(33.33),
                qrPayload: "p"
            )
        )
        #expect(viewModel.perPersonText.hasSuffix(" VND"))
        #expect(viewModel.perPersonText.contains("33"))
    }

    @Test
    func theSourceSubtitleJoinsTheCounterpartyAndTheDate() {
        let viewModel = makeViewModel()

        let subtitle = viewModel.sourceSubtitle

        #expect(subtitle.hasPrefix("Binh Tran · "))
        #expect(subtitle.count > "Binh Tran · ".count)
    }

    // MARK: - Identity

    @Test
    func identityIsTheHashableBasis() {
        let viewModel = makeViewModel()
        let other = makeViewModel()

        #expect(viewModel == viewModel)
        #expect(viewModel != other)

        var set: Set<SplitFlowViewModel> = [viewModel]
        #expect(set.contains(viewModel))
        set.insert(other)
        #expect(set.count == 2)
    }
}
