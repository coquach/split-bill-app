//
//  SplitSetupViewModel.swift
//  SplitBill
//
//  Created by Dinh Long on 28/9/26.
//

import Domains
import Foundation
import Observation

@MainActor
@Observable
public final class SplitSetupViewModel {

    public enum State: Equatable {
        case idle
        case creating
        case failed(DomainError)
    }

    public let source: SplitSource

    public let editingSplitBillId: UUID?

    public var participantCount: Int = 2

    public private(set) var state: State = .idle

    public static let participantRange = 2...20

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

    public func dismissError() {
        guard case .failed = state else { return }
        state = .idle
    }

    public func generateQR() async -> SplitQRContext? {
        guard state != .creating else { return nil }

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
            let creation = try await splitBillRepository.createSplitBill(command)

            guard let qrCode = creation.qrCode else {
                state = .failed(
                    .unknown(
                        code: "QR_NOT_RETURNED",
                        message: "The split was created but its QR code wasn't returned."
                    )
                )
                return nil
            }

            state = .idle

            return SplitQRContext(
                splitBillId: creation.splitBill.id,
                title: creation.splitBill.title,
                counterpartyName: source.counterpartyName,
                participantCount: creation.splitBill.participantCount,
                perPersonAmount: creation.splitBill.perPersonAmount,
                qrPayload: qrCode.qrPayload
            )
        } catch let error as DomainError {
            state = .failed(error)
            return nil
        } catch {
            state = .failed(
                .unknown(code: nil, message: error.localizedDescription)
            )
            return nil
        }
    }

    private func updateExisting(id: UUID) async -> SplitQRContext? {
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

            state = .idle

            return SplitQRContext(
                splitBillId: updated.id,
                title: updated.title,
                counterpartyName: source.counterpartyName,
                participantCount: updated.participantCount,
                perPersonAmount: updated.perPersonAmount,
                qrPayload: qr.qrPayload
            )
        } catch let error as DomainError {
            state = .failed(error)
            return nil
        } catch {
            state = .failed(
                .unknown(code: nil, message: error.localizedDescription)
            )
            return nil
        }
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
}
