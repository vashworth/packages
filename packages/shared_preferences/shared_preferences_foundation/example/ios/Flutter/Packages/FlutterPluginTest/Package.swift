// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FlutterPluginTests",
    platforms: [
        .iOS("12.0"),
    ],
    dependencies: [
        .package(path: "../ephemeral/FlutterGeneratedPluginSwiftPackage"),
        .package(name: "shared_preferences_foundation", path: "../ephemeral/.symlinks/plugins/shared_preferences_foundation/darwin/shared_preferences_foundation")
    ],
    targets: [
        .testTarget(
            name: "FlutterPluginTests",
            dependencies: [
                "FlutterGeneratedPluginSwiftPackage",
                .product(name: "shared_preferences_foundation_test", package: "shared_preferences_foundation")
            ]
        )
    ]
)
