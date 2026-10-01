//
//  TransferStatusDatabaseTests.swift
//  DomainDatasTests
//

import Domains
import Testing

@testable import DomainDatas

@Suite("TransferStatus.fromDatabase")
struct TransferStatusDatabaseTests {

    @Test(arguments: [("SUCCESS", TransferStatus.success), ("success", TransferStatus.success)])
    func readsTheSuccessStatus(raw: String, expected: TransferStatus) {
        #expect(TransferStatus(fromDatabase: raw) == expected)
    }

    @Test
    func readsPendingAndFailed() {
        #expect(TransferStatus(fromDatabase: "PENDING") == .pending)
        #expect(TransferStatus(fromDatabase: "FAILED") == .failed)
    }

    @Test
    func defaultsAnUnrecognisedValueToPending() {
        // With money, "I don't know what this means" must read as
        // "not finished yet", never "it went through".
        #expect(TransferStatus(fromDatabase: "WHATEVER") == .pending)
        #expect(TransferStatus(fromDatabase: "") == .pending)
    }
}
