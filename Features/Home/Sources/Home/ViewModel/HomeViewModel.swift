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
    private(set) var email: String
    private(set) var wallet: Wallet?
    private(set) var recentTransfers: [HomeTransaction] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let userId: UUID
    private let authRepository: IAuthRepository
    private let walletRepository: IWalletRepository
    private let transferRepository: ITransferRepository

    public init(
        user: User,
        authRepository: IAuthRepository,
        walletRepository: IWalletRepository,
        transferRepository: ITransferRepository
    ) {
        self.email = user.email
        self.userId = user.id
        self.authRepository = authRepository
        self.walletRepository = walletRepository
        self.transferRepository = transferRepository
    }

    var displayName: String {
        if let wallet,
            !wallet.walletHolderName.trimmingCharacters(
                in: .whitespacesAndNewlines
            ).isEmpty
        {
            return
                "Hi, \(wallet.walletHolderName.split(separator: " ").last.map(String.init) ?? wallet.walletHolderName)"
        }
        return
            "Hi, \(email.split(separator: "@").first.map(String.init) ?? email)"
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
            async let walletTask = walletRepository.getDefaultWallet()
            async let transferTask = transferRepository.getTransfers()

            let (loadedWallet, transfers) = try await (walletTask, transferTask)
            wallet = loadedWallet
            recentTransfers = transfers.prefix(4).map {
                HomeTransaction(transaction: $0, currentUserId: userId)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func logout() async {
        do {
            try await authRepository.signOut()
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

    public init(transaction: TransferTransaction, currentUserId: UUID) {
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
