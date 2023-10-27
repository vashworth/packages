// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FlutterTestPackage",
    products: [
        .library(name: "FlutterTestPackage", targets: ["FlutterTestPackage"]),
    ],
    dependencies: [
        .package(name: "image_picker_ios", path: "/Users/vashworth/Development/packages/packages/image_picker/image_picker_ios/ios/image_picker_ios"),
    ],
    targets: [
        .target(
            name: "FlutterTestPackage",
            dependencies: [
                .product(name: "image_picker_ios_test_lib", package: "image_picker_ios"),
            ]
        ),
    ]
)
