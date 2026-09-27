import Foundation

public struct CreateTransferCommand: Sendable, Equatable {
    public let recipientWalletId: UUID
    public let amount: Int64
    public let description: String?
    public let pin: String
    public let idempotencyKey: String

    public init(recipientWalletId: UUID, amount: Int64, description: String?, pin: String, idempotencyKey: String) {
        self.recipientWalletId = recipientWalletId
        self.amount = amount
        self.description = description
        self.pin = pin
        self.idempotencyKey = idempotencyKey
    }
}

public struct CreateSplitBillCommand: Sendable, Equatable {
    public let title: String
    public let note: String?
    public let participantCount: Int
    public let sourceTransferId: UUID
    public let idempotencyKey: String
    public let expiryDays: Int

    public init(title: String, note: String?, participantCount: Int, sourceTransferId: UUID, idempotencyKey: String, expiryDays: Int) {
        self.title = title
        self.note = note
        self.participantCount = participantCount
        self.sourceTransferId = sourceTransferId
        self.idempotencyKey = idempotencyKey
        self.expiryDays = expiryDays
    }
}

public struct UpdateSplitBillCommand: Sendable, Equatable {
    public let splitBillId: UUID
    public let title: String?
    public let note: String?
    public let participantCount: Int?
    public let expiresAt: Date?

    public init(splitBillId: UUID, title: String?, note: String?, participantCount: Int?, expiresAt: Date?) {
        self.splitBillId = splitBillId
        self.title = title
        self.note = note
        self.participantCount = participantCount
        self.expiresAt = expiresAt
    }
}

public struct GenerateSplitQRCommand: Sendable, Equatable {
    public let splitBillId: UUID

    public init(splitBillId: UUID) {
        self.splitBillId = splitBillId
    }
}

public struct CreateQRRepaymentCommand: Sendable, Equatable {
    public let qrPayload: String
    public let pin: String
    public let note: String?
    public let idempotencyKey: String

    public init(qrPayload: String, pin: String, note: String?, idempotencyKey: String) {
        self.qrPayload = qrPayload
        self.pin = pin
        self.note = note
        self.idempotencyKey = idempotencyKey
    }
}
