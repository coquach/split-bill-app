//
//  Bundle+Supabase.swift
//  SplitPay
//
//  Created by Co Quach on 18/9/26.
//

import Foundation

extension Bundle {
    var supabaseURL: URL {
        guard
            let value = object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
            let url = URL(string: value)
        else {
            fatalError("SUPABASE_URL is missing or invalid in Info.plist")
        }
        return url
    }

    var supabaseKey: String {
        guard let value = object(forInfoDictionaryKey: "SUPABASE_KEY") as? String else {
            fatalError("SUPABASE_KEY is missing in Info.plist")
        }
        return value
    }
}
