// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FlutterPluginTest",
    platforms: [
        .iOS("12.0"),
    ],
    dependencies: [
        .package(name: "camera_avfoundation", path: "../../../../../ios/camera_avfoundation")
    ],
    targets: [
        .testTarget(
            name: "FlutterPluginTest",
            dependencies: [
                .product(name: "camera_avfoundation_test", package: "camera_avfoundation")
            ]
        )
    ]
)
