// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "SplitBill",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "SplitBill",
            targets: ["SplitBill"]
        ),
    ],
    dependencies: [
        .package(path: "../../Foundation/Domains"),
        .package(path: "../../Foundation/Router"),
        .package(path: "../../Foundation/SystemDesign"),
    ],
    targets: [
        .target(
            name: "SplitBill",
            dependencies: [
                .product(name: "Domains", package: "Domains"),
                .product(name: "Router", package: "Router"),
                .product(name: "SystemDesign", package: "SystemDesign"),
            ]
        ),
        .testTarget(
            name: "SplitBillTests",
            dependencies: [
                "SplitBill",
                .product(name: "Domains", package: "Domains"),
            ]
        ),
    ]
)
