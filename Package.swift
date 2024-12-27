// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OpenAISwift",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "OpenAISwift",
            targets: ["OpenAISwift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-testing.git", from: "0.1.0")
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
                "OpenAISwift",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "OpenAISwiftTests"
        ),
    ]
)
