// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FlutterPluginTest",
    platforms: [
        .iOS("12.0"),
    ],
    dependencies: [
        .package(name: "image_picker_ios", path: "../../../../../ios/image_picker_ios")
    ],
    targets: [
        .testTarget(
            name: "FlutterPluginTest",
            dependencies: [
                .product(name: "image_picker_ios_test", package: "image_picker_ios")
            ]
        )
    ]
)
