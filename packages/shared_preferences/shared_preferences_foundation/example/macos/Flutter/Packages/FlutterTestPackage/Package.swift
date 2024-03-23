// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FlutterTestPackage",
    platforms: [
        .iOS("12.0"),
    ],
    products: [
        .library(name: "FlutterTestPackage", targets: ["FlutterPluginTests"])
    ],
    dependencies: [
        .package(path: "../FlutterGeneratedPluginSwiftPackage"),
        .package(name: "shared_preferences_foundation", path: "../../../../../darwin/shared_preferences_foundation")
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
