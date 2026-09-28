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

        do {
            async let profileTask = profileRepository.getCurrentProfile()
            async let walletTask = walletRepository.getDefaultWallet()
            async let transferTask = transferRepository.getTransfers(page: 1, pageSize: 10, filter: .all)

            let (
                loadedProfile,
                loadedWallet,
                transfers
            ) = try await (
                profileTask,
                walletTask,
                transferTask
            )

            profile = loadedProfile
            wallet = loadedWallet
            
            recentTransfers = transfers.prefix(4).map {
                HomeTransaction(transaction: $0, currentUserId: loadedProfile.id)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
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
    public let currency: String
    public let createdAt: Date

    public init(transaction: TransferHistory, currentUserId: UUID) {
        id = transaction.id
        title = "Transfer"
        subtitle = transaction.transactionRef
        amount =
            transaction.senderUserId == currentUserId
            ? -transaction.amount : transaction.amount
        currency = transaction.currency
        createdAt = transaction.createdAt
    }

    var isIncoming: Bool { amount > 0 }

    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let value = formatter.string(from: NSNumber(value: abs(amount))) ?? "0"
        return "\(isIncoming ? "+" : "-")\(value) \(currency)"
    }

    var dateText: String {
        DateFormatting.relative(createdAt)
    }

}
