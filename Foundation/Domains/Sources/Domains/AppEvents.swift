//
//  AppEvents.swift
//  Domains
//

import Foundation

public extension Notification.Name {
    // Posted right after a transfer or split repayment succeeds, so every list that shows transactions can reload.
    static let transactionsDidChange = Notification.Name("SplitPay.transactionsDidChange")
}
