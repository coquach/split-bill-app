//
//  AccountLookupState.swift
//  
//
//  Created by Dinh Long on 25/9/26.
//

import Domains

public enum AccountLookupState: Equatable {
    case idle
    case loading
    case found(ResolvedAccount)
    case notFound
    case failed(String)
}
