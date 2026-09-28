import Foundation

public enum UserStatus: String, Codable, Sendable, Equatable { case active = "ACTIVE"; case blocked = "BLOCKED" }
public enum WalletStatus: String, Codable, Sendable, Equatable { case active = "ACTIVE"; case inactive = "INACTIVE"; case frozen = "FROZEN" }
public enum TransferStatus: String, Codable, Sendable, Equatable { case pending = "PENDING"; case success = "SUCCESS"; case failed = "FAILED" }
public enum SplitBillStatus: String, Codable, Sendable, Equatable { case active = "ACTIVE"; case expired = "EXPIRED"; case closed = "CLOSED"; case cancelled = "CANCELLED" }
public enum RepaymentStatus: String, Codable, Sendable, Equatable { case success = "SUCCESS"; case failed = "FAILED"; case refunded = "REFUNDED" }
public enum PaymentMethod: String, Codable, Sendable, Equatable { case splitQR = "SPLIT_QR" }

public enum SplitBillRoleFilter: String, Codable, Sendable, Equatable {
    case created = "CREATED"
    case repaid = "REPAID"
}

public enum SplitBillStatusFilter: String, Codable, Sendable, Equatable {
    case all = "ALL"
    case active = "ACTIVE"
    case closed = "CLOSED"
    case expired = "EXPIRED"
}
