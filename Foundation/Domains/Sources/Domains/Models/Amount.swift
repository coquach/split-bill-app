//
//  Amount.swift
//  Domains
//
//  Created by Dinh Long on 26/9/26.
//

import Foundation

/// A monetary value. VND has no sub-unit, so this deliberately wraps a
/// plain `Double` instead of the usual Int64-minor-unit pattern — see
/// CLAUDE.md for why.
///
/// Because it's backed by a `Double`, never compare two `Amount` values
/// with `==` after doing arithmetic on them (e.g. summed repayments vs.
/// a total) — floating-point rounding can make that comparison false
/// even when the values are "the same" to the user. Compare with a
/// small epsilon instead.
public struct Amount: Sendable, Equatable, Hashable, Comparable, Codable {
    public let amount: Double

    public init(_ amount: Double) {
        self.amount = amount
    }

    public static func < (lhs: Amount, rhs: Amount) -> Bool {
        lhs.amount < rhs.amount
    }

    /// Always shows 0 fraction digits, regardless of the underlying
    /// Double's precision, since VND is never split into sub-units.
    public var formatted: String {
        formatted(maximumFractionDigits: 0)
    }

    /// Shows up to `maximumFractionDigits` decimals, dropping trailing
    /// zeros. Used by the split calculation, where a share divides to
    /// something like 13.333 and rounding it away to a whole dong would
    /// make the parts visibly fail to add back up to the total.
    public func formatted(maximumFractionDigits: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = maximumFractionDigits
        return formatter.string(from: NSNumber(value: amount))
            ?? "\(amount)"
    }
}
