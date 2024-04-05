// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FlutterPluginTest",
    platforms: [
        .macOS("10.14"),
    ],
    dependencies: [
        .package(name: "shared_preferences_foundation", path: "../../../../../darwin/shared_preferences_foundation")
    ],
    targets: [
        .testTarget(
            name: "FlutterPluginTest",
            dependencies: [
                .product(name: "shared_preferences_foundation_test", package: "shared_preferences_foundation")
            ]
        )
    ]
)
