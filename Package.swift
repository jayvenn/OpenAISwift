// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OpenAISwift",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "OpenAISwift",
            targets: ["OpenAISwift"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "OpenAISwift",
            dependencies: [],
            path: "OpenAISwift"
        ),
        .testTarget(
            name: "OpenAISwiftTests",
            dependencies: [
                "OpenAISwift"
            ],
            path: "OpenAISwiftTests"
        ),
    ]
)
