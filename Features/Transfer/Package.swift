// swift-tools-version: 6.2
//
//  Package.swift
//
//
//  Created by Dinh Long on 25/9/26.
//

import PackageDescription

let package = Package(
    name: "Transfer",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Transfer",
            targets: ["Transfer"]
        ),
    ],
    dependencies: [
        .package(path: "../../Foundation/Domains"),
        .package(path: "../../Foundation/Router"),
        .package(path: "../../Foundation/SystemDesign"),
        .package(path: "../../Core/CommonUi"),
    ],
    targets: [
        .target(
            name: "Transfer",
            dependencies: [
                .product(name: "Domains", package: "Domains"),
                .product(name: "Router", package: "Router"),
                .product(name: "SystemDesign", package: "SystemDesign"),
                .product(name: "CommonUi", package: "CommonUi"),
            ]
        ),
        .testTarget(
            name: "TransferTests",
            dependencies: ["Transfer"]
        ),
    ]
)
