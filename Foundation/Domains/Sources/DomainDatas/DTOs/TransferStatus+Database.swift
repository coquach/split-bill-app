//
//  TransferStatus+Database.swift
//  DomainDatas
//
//  Created by Dinh Long on 28/9/26.
//

import Domains

extension TransferStatus {
    /// `transfer_transactions.status` is a plain `character varying`, not a
    /// Postgres enum, so nothing at the type level guarantees the casing or
    /// that the value is one of the three we know about.
    ///
    /// Anything unrecognised becomes `.pending` rather than `.success`: with
    /// money, the safe reading of "I don't know what this means" is
    /// "not finished yet", never "it went through".
    init(fromDatabase raw: String) {
        self = TransferStatus(rawValue: raw.uppercased()) ?? .pending
    }
}
