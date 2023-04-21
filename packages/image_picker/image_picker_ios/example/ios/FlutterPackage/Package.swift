// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FlutterPackage",
    products: [
        .library(name: "FlutterPackage", targets: ["FlutterPackage"]),
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "/Users/vashworth/Development/flutter/bin/cache/artifacts/engine/ios"),
        .package(name: "image_picker_ios", path: "/Users/vashworth/Development/packages/packages/image_picker/image_picker_ios/ios/image_picker_ios"),
        .package(name: "integration_test", path: "/Users/vashworth/Development/flutter/packages/integration_test/ios/integration_test"),
    ],
    targets: [
        .target(
            name: "FlutterPackage",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "image_picker_ios", package: "image_picker_ios"),
                .product(name: "integration_test", package: "integration_test"),
            ]
        )
    ]

)
