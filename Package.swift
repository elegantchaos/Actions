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
        .library(
            name: "ActionsTestSupport",
            targets: ["ActionsTestSupport"]),
    ],
    dependencies: [
        .package(url: "https://github.com/elegantchaos/Logger.git", from: "1.5.3"),
    ],
    targets: [
        .target(
            name: "Actions",
            dependencies: ["Logger"]),
        .target(
            name: "ActionsTestSupport",
            dependencies: ["Actions"]),
        .testTarget(
            name: "ActionsTests",
            dependencies: ["Actions", "ActionsTestSupport"]),
    ]
)
