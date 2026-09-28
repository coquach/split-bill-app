//
//  PostgresNumeric.swift
//  DomainDatas
//
//  Created by Dinh Long on 28/9/26.
//

import Foundation

/// A Postgres `numeric` column as it arrives over PostgREST.
///
/// Depending on the PostgREST version and the column's precision, the same
/// value can come across as an unquoted JSON number (`10000.00`) or as a
/// quoted string (`"10000.00"`) — the string form exists to avoid losing
/// precision on values a double can't hold exactly. Betting on one form and
/// getting the other is a decode failure, and for `wallets.balance` that
/// failure is near-silent: the balance stays at zero and the Transfer screen
/// just refuses to enable Continue, with nothing on screen to explain why.
///
/// So accept both. VND has no sub-unit, so `Double` is wide enough here —
/// see `Amount` in Domains for why this project uses Double for money.
struct PostgresNumeric: Decodable, Sendable, Equatable {
    let value: Double

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        // The common case: PostgREST sent a bare JSON number.
        if let number = try? container.decode(Double.self) {
            value = number
            return
        }

        // Otherwise it must be the quoted form, or the column isn't numeric
        // at all and something upstream has changed.
        let raw = try container.decode(String.self)

        guard let number = Double(raw) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription:
                    "Expected a Postgres numeric, got \"\(raw)\"."
            )
        }

        value = number
    }
}
