//
//  Amount.swift
//  SplitPay
//
//  Created by Dinh Long on 14/9/26.
//

import Foundation

struct Amount: Equatable, Hashable, Codable {

    let amount: Double

    init(amount: Double) {
        self.amount = amount
    }

    static let zero = Amount(amount: 0)

    func adding(_ other: Amount) -> Amount {
        Amount(amount: amount + other.amount)
    }

    func subtracting(_ other: Amount) -> Amount {
        Amount(amount: amount - other.amount)
    }

    func isLessThan(_ other: Amount) -> Bool {
        amount < other.amount
    }

    var formatted: String {
        Amount.numberFormatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }

    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.usesGroupingSeparator = true
        formatter.maximumFractionDigits = 0
        return formatter
    }()
}
