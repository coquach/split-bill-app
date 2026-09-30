//
//  Fixtures.swift
//  SplitBillTests
//

import Domains
import Foundation

func makeSource(
    transferId: UUID = UUID(),
    title: String = "Team lunch",
    counterpartyName: String = "Binh Tran",
    date: Date = Date(timeIntervalSince1970: 1_700_000_000),
    totalAmount: Amount = Amount(100)
) -> SplitSource {
    SplitSource(
        transferId: transferId,
        title: title,
        counterpartyName: counterpartyName,
        date: date,
        totalAmount: totalAmount
    )
}

func makeSplitBill(
    id: UUID = UUID(),
    title: String = "Team lunch",
    participantCount: Int = 3,
    perPersonAmount: Amount = Amount(33.33),
    requesterAmount: Amount = Amount(33.34),
    status: SplitBillStatus = .active,
    expiresAt: Date? = Date(timeIntervalSince1970: 1_800_000_000)
) -> SplitBill {
    SplitBill(
        id: id,
        requesterId: UUID(),
        sourceTransferId: UUID(),
        title: title,
        note: nil,
        totalAmount: Amount(100),
        currency: "VND",
        participantCount: participantCount,
        perPersonAmount: perPersonAmount,
        requesterAmount: requesterAmount,
        requiredSlots: participantCount - 1,
        paidSlots: 0,
        remainingSlots: participantCount - 1,
        status: status,
        expiresAt: expiresAt,
        closedAt: nil,
        createdAt: Date(timeIntervalSince1970: 1_700_000_000),
        updatedAt: Date(timeIntervalSince1970: 1_700_000_000)
    )
}

func makeListItem(
    id: UUID = UUID(),
    title: String = "Team lunch",
    totalAmount: Int64 = 100_000,
    perPersonAmount: Int64 = 50000,
    requiredSlots: Int = 2,
    paidSlots: Int = 1,
    status: SplitBillStatus = .active
) -> SplitBillListItem {
    SplitBillListItem(
        id: id,
        requesterId: UUID(),
        sourceTransferId: UUID(),
        title: title,
        note: nil,
        totalAmount: totalAmount,
        currency: "VND",
        participantCount: requiredSlots + 1,
        perPersonAmount: perPersonAmount,
        requesterAmount: perPersonAmount,
        requiredSlots: requiredSlots,
        paidSlots: paidSlots,
        status: status,
        expiresAt: nil,
        closedAt: nil,
        createdAt: Date(timeIntervalSince1970: 1_700_000_000),
        isRequester: true,
        hasRepaid: false
    )
}

func makeDetail(
    splitBill: SplitBill = makeSplitBill()
) -> SplitBillDetail {
    SplitBillDetail(
        splitBill: splitBill,
        transferStatus: .success,
        transactionRef: "TX-001",
        qrId: UUID(),
        qrPayload: "qr-payload",
        qrImageURL: nil,
        qrIsActive: true,
        qrExpiresAt: splitBill.expiresAt,
        isRequester: true,
        hasRepaid: false,
        canUpdate: true,
        canClose: true,
        canRepay: false
    )
}

func makeRepayment(
    amount: Amount = Amount(33.33),
    status: RepaymentStatus = .success,
    paidAt: Date? = Date(timeIntervalSince1970: 1_700_000_100)
) -> Repayment {
    Repayment(
        id: UUID(),
        splitBillId: UUID(),
        payerUserId: UUID(),
        transferTransactionId: UUID(),
        paymentMethod: .qrTransfer,
        amount: amount,
        currency: "VND",
        payerDisplayName: "Binh Tran",
        note: nil,
        status: status,
        idempotencyKey: UUID().uuidString,
        paidAt: paidAt,
        createdAt: Date(timeIntervalSince1970: 1_700_000_000)
    )
}

func makeQRCode(
    splitBillId: UUID = UUID(),
    qrPayload: String = "qr-payload"
) -> SplitQRCode {
    SplitQRCode(
        id: UUID(),
        splitBillId: splitBillId,
        walletId: UUID(),
        qrPayload: qrPayload,
        isActive: true,
        expiresAt: nil,
        createdAt: Date(timeIntervalSince1970: 1_700_000_000),
        updatedAt: Date(timeIntervalSince1970: 1_700_000_000)
    )
}

func makeReview(
    title: String = "Team lunch",
    requesterName: String? = "Binh Tran",
    perPersonAmount: Int64 = 33330
) -> SplitQRReview {
    SplitQRReview(
        splitBillId: UUID(),
        title: title,
        requesterName: requesterName,
        amount: 100_000,
        currency: "VND",
        perPersonAmount: perPersonAmount,
        remainingSlots: 2
    )
}

func makeReceipt(
    amount: Amount = Amount(33.33),
    paidSlots: Int = 1
) -> QRRepaymentReceipt {
    QRRepaymentReceipt(
        id: UUID(),
        splitBillId: UUID(),
        transferTransactionId: UUID(),
        amount: amount,
        paymentMethod: .qrTransfer,
        status: .success,
        paidSlots: paidSlots,
        splitBillStatus: .active,
        paidAt: Date(timeIntervalSince1970: 1_700_000_100)
    )
}
