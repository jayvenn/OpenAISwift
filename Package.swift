// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "OpenAISwift",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "OpenAISwift",
            targets: ["OpenAISwift"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "OpenAISwift",
            path: "OpenAISwift"),
        .testTarget(
            name: "OpenAISwiftTests",
            dependencies: ["OpenAISwift"]),
    ]
)
