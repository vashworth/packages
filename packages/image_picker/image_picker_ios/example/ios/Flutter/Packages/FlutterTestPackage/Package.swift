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
        .package(path: "../FlutterPackage"),
        .package(name: "image_picker_ios", path: "../../../../../ios/image_picker_ios")
    ],
    targets: [
        .testTarget(
            name: "FlutterPluginTests",
            dependencies: [
                "FlutterPackage",
                .product(name: "image_picker_ios_test", package: "image_picker_ios")
            ]
        )
    ]
)