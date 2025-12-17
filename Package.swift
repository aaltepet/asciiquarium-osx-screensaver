// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AsciiquariumCore",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "AsciiquariumCore",
            targets: ["AsciiquariumCore"])
    ],
    targets: [
        .target(
            name: "AsciiquariumCore",
            path: "Sources/AsciiquariumCore"),
        .testTarget(
            name: "AsciiquariumCoreTests",
            dependencies: ["AsciiquariumCore"],
            path: "Tests/AsciiquariumCoreTests"),
    ]
)
