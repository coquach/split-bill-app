//
//  DateFormattingTests.swift
//  UtilsTests
//

import Foundation
import Testing
import Utils

@Suite("DateFormatting.relative")
struct DateFormattingTests {
    /// Fixed reference so the tests never race the real clock. Exact
    /// strings are locale-dependent, so the tests assert structure —
    /// different offsets must render differently, same inputs identically.
    private static let reference = Date(timeIntervalSince1970: 1_700_000_000)

    @Test(arguments: [
        -86400.0, -3600.0, -60.0, 0.0, 60.0, 3600.0, 86400.0
    ])
    func rendersADistinctStringPerOffset(offset: TimeInterval) {
        let date = Self.reference.addingTimeInterval(offset)
        #expect(!DateFormatting.relative(date, relativeTo: Self.reference).isEmpty)
    }

    @Test
    func differentOffsetsRenderDifferently() {
        let minuteAgo = Self.reference.addingTimeInterval(-60)
        let hourAgo = Self.reference.addingTimeInterval(-3600)
        let dayAgo = Self.reference.addingTimeInterval(-86400)

        let strings = [
            DateFormatting.relative(minuteAgo, relativeTo: Self.reference),
            DateFormatting.relative(hourAgo, relativeTo: Self.reference),
            DateFormatting.relative(dayAgo, relativeTo: Self.reference)
        ]

        #expect(Set(strings).count == 3)
    }

    @Test
    func theSameInputsRenderTheSameOutput() {
        let date = Self.reference.addingTimeInterval(-90)
        #expect(
            DateFormatting.relative(date, relativeTo: Self.reference)
                == DateFormatting.relative(date, relativeTo: Self.reference)
        )
    }

    @Test
    func aFutureDateRendersDifferentlyFromItsPastEquivalent() {
        let future = DateFormatting.relative(
            Self.reference.addingTimeInterval(3600),
            relativeTo: Self.reference
        )
        let past = DateFormatting.relative(
            Self.reference.addingTimeInterval(-3600),
            relativeTo: Self.reference
        )
        #expect(future != past)
    }
}
