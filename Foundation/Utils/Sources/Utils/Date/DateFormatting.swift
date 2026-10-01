//
//  DateFormatting.swift
//  Utils
//
//  Created by Co Quach on 27/9/26.
//

import Foundation

public enum DateFormatting {

    public static func relative(
        _ date: Date,
        relativeTo referenceDate: Date = Date()
    ) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full

        return formatter.localizedString(
            for: date,
            relativeTo: referenceDate
        )
    }
}
