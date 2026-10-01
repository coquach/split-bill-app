// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

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
    ],
    targets: [
        .target(
            name: "Transfer",
            dependencies: [
                .product(name: "Domains", package: "Domains"),
                .product(name: "Router", package: "Router"),
                .product(name: "SystemDesign", package: "SystemDesign"),
            ]
        ),
        .testTarget(
            name: "TransferTests",
            dependencies: [
                "Transfer",
                .product(name: "Domains", package: "Domains"),
            ]
        ),
    ]
)
