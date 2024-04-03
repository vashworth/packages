// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FlutterPluginTest",
    platforms: [
        .iOS("14.0"),
    ],
    dependencies: [
        .package(path: "../ephemeral/FlutterGeneratedPluginSwiftPackage"),
        .package(name: "google_maps_flutter_ios", path: "../ephemeral/.symlinks/plugins/google_maps_flutter_ios/ios/google_maps_flutter_ios")
    ],
    targets: [
        .testTarget(
            name: "FlutterPluginTest",
            dependencies: [
                "FlutterGeneratedPluginSwiftPackage",
                .product(name: "google_maps_flutter_ios_test", package: "google_maps_flutter_ios")
            ]
        )
    ]
)
