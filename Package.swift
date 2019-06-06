// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Actions",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Actions",
            targets: ["Actions"]),
        .library(
            name: "ActionsKit",
            targets: ["ActionsKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/elegantchaos/Logger", from: "1.3.5"),
        .package(url: "https://github.com/elegantchaos/Coverage", from: "1.0.2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "ActionsKit",
            dependencies: ["Actions"]),
        .target(
            name: "Actions",
            dependencies: ["Logger"]),
        .testTarget(
            name: "ActionsTests",
            dependencies: ["Actions"]),
    ]
)
