// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FlutterPackage",
    products: [
        .library(name: "FlutterPackage", targets: ["FlutterPackage"]),
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "/Users/vashworth/Development/flutter/bin/cache/artifacts/engine/ios/FlutterFramework"),
        .package(name: "image_picker_ios", path: "/Users/vashworth/Development/packages/packages/image_picker/image_picker_ios/ios/image_picker_ios"),
    ],
    targets: [
        .target(
            name: "FlutterFrameworks",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
            ]
        ),
        .target(
            name: "FlutterPackage",
            dependencies: [
                "FlutterFramework",
                .product(name: "image_picker_ios", package: "image_picker_ios"),
            ]
        ),
    ]

)
