//
//  AppAlert.swift
//  CommonUi
//
//  Created by Co Quach on 18/9/26.
//

import Foundation

public struct AppAlert: Identifiable, Equatable, Sendable {

    public let id = UUID()
    public let title: String
    public let message: String

    public init(
        title: String,
        message: String
    ) {
        self.title = title
        self.message = message
    }
}
