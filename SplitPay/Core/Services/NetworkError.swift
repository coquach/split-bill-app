//
//  NetworkError.swift
//  SplitPay
//
//  Created by Dinh Long on 14/9/26.
//

import Foundation

enum NetworkError: Error, Equatable {
    case accountNotFound
    case insufficientBalance
    case invalidAmount
    case transferFailed(message: String)
    case noConnection
    case decodingFailed
    
    var message: String {
        switch self {
        case .accountNotFound:
            return "This accountc cannot be found."
        case .insufficientBalance:
            return "Your balance is not enough for this transfer."
        case .invalidAmount:
            return "This amount is not valid."
        case .transferFailed(let message):
            return message
        case .noConnection:
            return "Couldn't reach the server. Check your connection and try again."
        case .decodingFailed:
            return "Something went wrong on our end. Please try again."
        }
    }
}
