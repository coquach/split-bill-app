//
//  SessionStore.swift
//  SplitPay
//
//  Created by Dinh Long on 14/9/26.
//

import Foundation
import Combine

public class SessionStore: ObservableObject {
    @Published private(set) var availableBalance: Amount = .zero
    
    private let balanceProvider: WalletBalanceProviding
    
    init(balanceProvider: WalletBalanceProviding) {
        self.balanceProvider = balanceProvider
    }
    
    func refreshBalance() async {
        do {
            let balance = try await balanceProvider.fetchAvailableBalance()
            availableBalance = balance
        } catch {
            
        }
    }
}
