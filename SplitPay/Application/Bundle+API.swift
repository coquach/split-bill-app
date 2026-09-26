//
//  Bundle+API.swift
//  SplitPay
//
//  Created by Dinh Long on 25/9/26.
//

import Foundation

extension Bundle {
    var apiBaseURL: URL {
        guard
            let value = object(forInfoDictionaryKey: "API_BASE_URL") as? String,
            let url = URL(string: value)
        else {
            fatalError("API_BASE_URL is missing or invalid in Info.plist")
        }
        return url
    }
}
