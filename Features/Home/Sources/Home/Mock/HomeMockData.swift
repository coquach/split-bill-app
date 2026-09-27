//
//  HomeMockData.swift
//  Home
//
//  Created by Co Quach on 18/9/26.
//

import Foundation

enum HomeMockData {

    static let userName = "Alex Morgan"

    static let balance = "12,450,000"

    static let lastFourDigits = "8829"

    static let transactions: [Transaction] = [
        .init(
            title: "Nguyen Van An",
            subtitle: "14:32 • Hotpot Dinner",
            amount: "+400,000",
            isIncome: true,
            icon: .person
        ),
        .init(
            title: "Coffee & Bistro",
            subtitle: "Yesterday • Breakfast",
            amount: "-120,000",
            isIncome: false,
            icon: .coffee
        ),
        .init(
            title: "HyperFiber Net",
            subtitle: "12 Oct • Apartment Wifi",
            amount: "-250,000",
            isIncome: false,
            icon: .wifi
        ),
        .init(
            title: "Tran Thi Mai",
            subtitle: "10 Oct • Grab Ride Share",
            amount: "+85,000",
            isIncome: true,
            icon: .person
        )
    ]

    struct Transaction: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let amount: String
        let isIncome: Bool
        let icon: Icon

        enum Icon {
            case person
            case coffee
            case wifi
        }
    }
}
