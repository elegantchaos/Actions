// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Actions",
    platforms: [
        .macOS(.v10_13), .iOS(.v12),
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Actions",
            targets: ["Actions"]),
        .library(
            name: "ActionsTestSupport",
            targets: ["ActionsTestSupport"]),
    ],
    dependencies: [
        .package(url: "https://github.com/elegantchaos/Logger.git", from: "1.3.6"),
        .package(url: "https://github.com/elegantchaos/Coverage.git", from: "1.0.6"),
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
