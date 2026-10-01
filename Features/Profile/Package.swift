// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Profile",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Profile",
            targets: ["Profile"]
        )
    ],
    dependencies: [
        .package(path: "../../Foundation/Domains"),
        .package(path: "../../Foundation/SystemDesign")
    ],
    targets: [
        .target(
            name: "Profile",
            dependencies: [
                .product(name: "Domains", package: "Domains"),
                .product(name: "SystemDesign", package: "SystemDesign")
            ]
        ),
        .testTarget(
            name: "ProfileTests",
            dependencies: [
                "Profile",
                .product(name: "Domains", package: "Domains"),
            ]
        )
    ]
)
