// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Domains",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "Domains",
            targets: ["Domains"]
        ),
        .library(
            name: "DomainDatas",
            targets: ["DomainDatas"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/supabase/supabase-swift.git",
            from: "2.55.2"
        ),
        .package(path: "../Network")
    ],
    targets: [
        .target(
            name: "Domains",
            path: "Sources/Domains"
        ),
        .target(
            name: "DomainDatas",
            dependencies: [
                "Domains",
                "Network",
                .product(
                    name: "Supabase",
                    package: "supabase-swift"
                ),
            ],
            path: "Sources/DomainDatas"
        ),
        .testTarget(
            name: "DomainsTests",
            dependencies: ["Domains"]
        ),
    ]
)
