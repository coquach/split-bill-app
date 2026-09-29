//
//  SplitFlowViewModel.swift
//  SplitBill
//
//  Created by Dinh Long on 30/9/26.
//

import Domains
import Foundation
import Observation
import SystemDesign
import UIKit

@MainActor
@Observable
public final class SplitFlowViewModel {

    public enum State: Equatable {
        case idle
        case creating
        case cancelling
        case failed(DomainError)
    }

    public let source: SplitSource
    public let editingSplitBillId: UUID?
    public var participantCount: Int

    public private(set) var state: State = .idle
    public var isShowingCancelConfirmation = false

    public static let participantRange = 2...10

    public private(set) var context: SplitQRContext?

    private let splitBillRepository: ISplitBillRepository
    private let splitQRRepository: ISplitQRRepository

    private let idempotencyKey = UUID().uuidString

    public init(
        source: SplitSource,
        splitBillRepository: ISplitBillRepository,
        splitQRRepository: ISplitQRRepository,
        editingSplitBillId: UUID? = nil,
        participantCount: Int = 2
    ) {
        self.source = source
        self.splitBillRepository = splitBillRepository
        self.splitQRRepository = splitQRRepository
        self.editingSplitBillId = editingSplitBillId
        self.participantCount = participantCount
    }

    // MARK: - Setup step

    public var isEditing: Bool {
        editingSplitBillId != nil
    }

    public var primaryActionTitle: String {
        isEditing ? "Update & Show QR" : "Generate QR"
    }

    private var split: SplitCalculator.Result {
        SplitCalculator.equalSplit(
            totalAmount: source.totalAmount,
            participantCount: participantCount
        )
    }

    public var amountPerPerson: Amount {
        split.perPersonAmount
    }

    public var requesterAmount: Amount {
        split.requesterAmount
    }

    public var splitsEvenly: Bool {
        split.splitsEvenly
    }

    public var amountPerPersonText: String {
        split.perPersonAmount.formatted(
            maximumFractionDigits: SplitCalculator.fractionDigits
        )
    }

    public var requesterAmountText: String {
        split.requesterAmount.formatted(
            maximumFractionDigits: SplitCalculator.fractionDigits
        )
    }

    public var errorMessage: String? {
        guard case .failed(let error) = state else { return nil }
        return error.message
    }

    public var isCreating: Bool {
        state == .creating
    }

    public var isCancelling: Bool {
        state == .cancelling
    }

    public func dismissError() {
        guard case .failed = state else { return }
        state = .idle
    }

    public func requestCancelConfirmation() {
        isShowingCancelConfirmation = true
    }

    public func dismissCancelConfirmation() {
        isShowingCancelConfirmation = false
    }

    // Reuses close_split_bill: closing an active split sets it to CANCELLED,
    // which the repayment RPCs already reject - same effect as "cancel".
    public func cancelSplit() async -> Bool {
        guard let editingSplitBillId else { return false }

        state = .cancelling

        do {
            _ = try await splitBillRepository.closeSplitBill(id: editingSplitBillId)
            isShowingCancelConfirmation = false
            state = .idle
            return true
        } catch let error as DomainError {
            isShowingCancelConfirmation = false
            state = .failed(error)
            return false
        } catch {
            isShowingCancelConfirmation = false
            state = .failed(.unknown(code: nil, message: error.localizedDescription))
            return false
        }
    }

    // Builds (or updates) the split bill and stores the resulting QR context
    // on this VM, so the QR screen reads it from here instead of a payload.
    @discardableResult
    public func generateQR() async -> Bool {
        guard state != .creating else { return false }

        state = .creating

        if let editingSplitBillId {
            return await updateExisting(id: editingSplitBillId)
        }

        let command = CreateSplitBillCommand(
            title: source.title,
            note: nil,
            participantCount: participantCount,
            sourceTransferId: source.transferId,
            idempotencyKey: idempotencyKey,
            expiryDays: 7
        )

        do {
            let bill = try await splitBillRepository.createSplitBill(command)

            // Creation returns the split alone; the QR it made is read separately.
            let qr = try await splitQRRepository.getQR(splitBillId: bill.id)

            context = SplitQRContext(
                splitBillId: bill.id,
                title: bill.title,
                counterpartyName: source.counterpartyName,
                participantCount: bill.participantCount,
                perPersonAmount: bill.perPersonAmount,
                qrPayload: qr.qrPayload
            )
            state = .idle
            return true
        } catch let error as DomainError {
            state = .failed(error)
            return false
        } catch {
            state = .failed(
                .unknown(code: nil, message: error.localizedDescription)
            )
            return false
        }
    }

    private func updateExisting(id: UUID) async -> Bool {
        do {
            let current = try await splitBillRepository.getSplitBillDetail(
                id: id
            )
            let bill = current.splitBill

            let updated = try await splitBillRepository.updateSplitBill(
                UpdateSplitBillCommand(
                    splitBillId: id,
                    title: bill.title,
                    note: bill.note,
                    participantCount: participantCount,
                    expiresAt: bill.expiresAt
                )
            )

            let qr = try await splitQRRepository.getQR(splitBillId: id)

            context = SplitQRContext(
                splitBillId: updated.id,
                title: updated.title,
                counterpartyName: source.counterpartyName,
                participantCount: updated.participantCount,
                perPersonAmount: updated.perPersonAmount,
                qrPayload: qr.qrPayload
            )
            state = .idle
            return true
        } catch let error as DomainError {
            state = .failed(error)
            return false
        } catch {
            state = .failed(
                .unknown(code: nil, message: error.localizedDescription)
            )
            return false
        }
    }

    // Used when the QR was already loaded elsewhere (Split Details'
    // "Download QR"), so the QR screen can reuse this VM without an
    // unnecessary create/update round-trip.
    public func setResolvedContext(_ context: SplitQRContext) {
        self.context = context
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    public var sourceSubtitle: String {
        let date = Self.dateFormatter.string(from: source.date)
        return "\(source.counterpartyName) · \(date)"
    }

    // MARK: - QR step

    public var subtitle: String {
        guard let context else { return "" }
        let noun = context.participantCount == 1 ? "person" : "people"
        return "\(context.counterpartyName) · \(context.participantCount) \(noun)"
    }

    public var perPersonText: String {
        guard let context else { return "" }
        let value = context.perPersonAmount.formatted(
            maximumFractionDigits: SplitCalculator.fractionDigits
        )
        return "\(value) VND"
    }

    public var qrImage: UIImage? {
        guard let context else { return nil }
        return QRCard.renderedImage(for: context.qrPayload)
    }
}

// Carried as a navigation destination payload, so it needs to be Hashable.
// Identity is enough - two flows are never "equal" just because their fields match.
extension SplitFlowViewModel: Hashable {
    public nonisolated static func == (lhs: SplitFlowViewModel, rhs: SplitFlowViewModel) -> Bool {
        lhs === rhs
    }

    public nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
