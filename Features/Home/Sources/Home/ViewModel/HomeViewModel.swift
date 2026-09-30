import Domains
//
//  HomeViewModel.swift
//  Home
//
//  Created by Co Quach on 18/9/26.
//
import Foundation
import Observation
import Utils

@MainActor
@Observable
public final class HomeViewModel {
    private(set) var profile: Profile?
    private(set) var wallet: Wallet?
    private(set) var recentTransfers: [HomeTransaction] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let profileRepository: IProfileRepository
    private let walletRepository: IWalletRepository
    private let transferRepository: ITransferRepository

    public init(
        profileRepository: IProfileRepository,
        walletRepository: IWalletRepository,
        transferRepository: ITransferRepository
    ) {
        self.profileRepository = profileRepository
        self.walletRepository = walletRepository
        self.transferRepository = transferRepository
        self.profile = nil
    }

    var displayName: String {
        let name =
            profile?.fullName?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            ?? "unknown"

        guard !name.isEmpty else {
            return "Hi"
        }

        return "Hi, \(name)"
    }

    var walletHolderName: String {
        wallet?.walletHolderName ?? ""
    }

    var currency: String {
        wallet?.currency ?? "VND"
    }

    var formattedBalance: String {
        guard let balance = wallet?.balance else { return "0" }
        return Self.numberFormatter.string(from: NSNumber(value: balance))
            ?? "0"
    }

    var lastFourWalletDigits: String {
        guard let number = wallet?.walletNumber else { return "••••" }
        return String(number.suffix(4))
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        async let profileTask = capture { try await profileRepository.getCurrentProfile() }
        async let walletTask = capture { try await walletRepository.getDefaultWallet() }
        async let transferTask = capture {
            try await transferRepository.getTransfers(page: 1, pageSize: 10, filter: .all)
        }

        let (profileResult, walletResult, transferResult) = await (
            profileTask, walletTask, transferTask
        )

        do {
            profile = try profileResult.get()
            wallet = try walletResult.get()
            let transfers = try transferResult.get()
            recentTransfers = transfers.prefix(3).map { HomeTransaction(transaction: $0) }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Captures a throw as a Result so one failing request doesn't cancel its
    /// siblings (which would surface as a misleading "unable to connect").
    private func capture<T>(_ work: () async throws -> T) async -> Result<T, Error> {
        do { return .success(try await work()) } catch { return .failure(error) }
    }

    func clearError() {
        errorMessage = nil
    }

    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.maximumFractionDigits = 0
        return formatter
    }()
}

public struct HomeTransaction: Identifiable, Sendable, Equatable {
    public let id: UUID
    public let title: String
    public let subtitle: String
    public let amount: Int64
    public let createdAt: Date

    public init(transaction: TransferHistory) {
        id = transaction.id
        title = transaction.counterpartyName
            ?? transaction.counterpartyWalletNumber
            ?? "Unknown"
        subtitle = transaction.isRepayment ? "Split payment" : "Transfer"
        amount = transaction.direction == .received
            ? transaction.amount
            : -transaction.amount
        createdAt = transaction.createdAt
    }

    var isIncoming: Bool { amount > 0 }

    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let value = formatter.string(from: NSNumber(value: abs(amount))) ?? "0"
        // The app only ever deals in VND - always show that instead of the
        // raw currency column, which has held stray non-code values.
        return "\(isIncoming ? "+" : "-")\(value) VND"
    }

    var dateText: String {
        DateFormatting.relative(createdAt)
    }

}
