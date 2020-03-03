// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Actions",
    platforms: [
        .macOS(.v10_13), .iOS(.v12),
    ],
    products: [
        .library(
            name: "Actions",
            targets: ["Actions"]),
    ],
    dependencies: [
        .package(url: "https://github.com/elegantchaos/Logger.git", from: "1.3.6"),
        .package(url: "https://github.com/elegantchaos/Coverage.git", from: "1.0.6"),
    ],
    targets: [
        .target(
            name: "Actions",
            dependencies: ["Logger"]),
        .testTarget(
            name: "ActionsTests",
            dependencies: ["Actions"]),
    ]
)
