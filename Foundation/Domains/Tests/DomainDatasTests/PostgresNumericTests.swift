//
//  PostgresNumericTests.swift
//  DomainDatasTests
//

import Foundation
import Testing

@testable import DomainDatas

@Suite("PostgresNumeric")
struct PostgresNumericTests {

    private func decode(_ json: String) throws -> PostgresNumeric {
        try JSONDecoder().decode(PostgresNumeric.self, from: Data(json.utf8))
    }

    @Test
    func decodesABareJsonNumber() throws {
        #expect(try decode("10000.00").value == 10000)
    }

    @Test
    func decodesAQuotedNumber() throws {
        #expect(try decode(#""10000.00""#).value == 10000)
    }

    @Test
    func decodesZeroInBothForms() throws {
        #expect(try decode("0").value == 0)
        #expect(try decode(#""0.00""#).value == 0)
    }

    @Test
    func rejectsAQuotedNonNumber() {
        // A non-numeric string means the column type changed upstream —
        // this must be a loud failure, not a silent zero balance.
        #expect(throws: DecodingError.self) {
            try decode(#""not-a-number""#)
        }
    }

    @Test
    func rejectsOtherJsonTypes() {
        #expect(throws: DecodingError.self) {
            try decode("true")
        }
    }
}
