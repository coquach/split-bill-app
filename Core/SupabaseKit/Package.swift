// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SupabaseKit",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "SupabaseKit",
            targets: ["SupabaseKit"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/supabase/supabase-swift.git",
            from: "2.55.2"
        )
    ],
    targets: [
        .target(
            name: "SupabaseKit",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift")
            ]
        ),
        .testTarget(
            name: "SupabaseKitTests",
            dependencies: ["SupabaseKit"]
        ),
    ]
)
