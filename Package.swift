// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "BowlingWesternRealityKit",
    platforms: [
        .iOS(.v17),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "BowlingWesternRealityKit",
            targets: ["BowlingWesternRealityKit"]
        )
    ],
    targets: [
        .target(
            name: "BowlingWesternRealityKit",
            path: "Sources/BowlingWesternRealityKit"
        )
    ]
)
