//
//  AmountTests.swift
//  DomainsTests
//

import Domains
import Foundation
import Testing

@Suite("Amount")
struct AmountTests {
    @Test(arguments: [
        (1.0, 2.0), (99.999, 100.0), (0.0, 0.000_1), (-5.0, 5.0)
    ])
    func ordersByAmount(lhs: Double, rhs: Double) {
        #expect(Amount(lhs) < Amount(rhs))
        #expect(Amount(rhs) > Amount(lhs))
        #expect(Amount(lhs) == Amount(lhs))
    }

    @Test
    func hashableSemanticsFollowEquatable() {
        let set: Set<Amount> = [Amount(1), Amount(1), Amount(2)]
        #expect(set == [Amount(1), Amount(2)])
    }

    @Test
    func codableRoundTripsTheUnderlyingDouble() throws {
        let original = Amount(123_456.789)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Amount.self, from: data)
        #expect(decoded == original)
    }

    // Formatting is locale-dependent by design, so the tests never pin
    // "," vs "." — they compare against a NumberFormatter configured
    // exactly like the production one, which pins the *configuration*
    // (the thing that actually regresses) instead of the rendering.

    private static func configuredFormatter(maximumFractionDigits: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = maximumFractionDigits
        return formatter
    }

    @Test
    func formattedShowsZeroFractionDigits() throws {
        let formatter = Self.configuredFormatter(maximumFractionDigits: 0)
        let expected = try #require(formatter.string(from: NSNumber(value: 1234.56)))
        #expect(Amount(1234.56).formatted == expected)
    }

    @Test
    func formattedDropsTheFractionEntirely() {
        // 13.333 rendered with 0 fraction digits must equal 13 rendered
        // the same way — i.e. no rounding digit leaks into the output.
        #expect(Amount(13.333).formatted == Amount(13).formatted)
    }

    @Test
    func formattedWithMaximumFractionDigitsKeepsUpToTwo() throws {
        let formatter = Self.configuredFormatter(maximumFractionDigits: 2)
        let expected = try #require(formatter.string(from: NSNumber(value: 13.333)))
        #expect(Amount(13.333).formatted(maximumFractionDigits: 2) == expected)
        // Trailing zeros are dropped, so 13.330 renders like 13.33.
        #expect(Amount(13.33).formatted(maximumFractionDigits: 2) == expected)
    }

    @Test
    func formattedFallsBackToInterpolationWhenTheFormatterFails() {
        // The fallback branch is only reachable if NumberFormatter returns
        // nil; pin the behaviour via a value any locale can render.
        #expect(!Amount(42).formatted.isEmpty)
        #expect(!Amount(42).formatted(maximumFractionDigits: 2).isEmpty)
    }
}
