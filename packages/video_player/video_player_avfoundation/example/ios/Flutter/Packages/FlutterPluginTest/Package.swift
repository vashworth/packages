// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FlutterPluginTest",
    platforms: [
        .iOS("12.0"),
    ],
    dependencies: [
        .package(path: "../ephemeral/FlutterGeneratedPluginSwiftPackage"),
        .package(name: "video_player_avfoundation", path: "../ephemeral/.symlinks/plugins/video_player_avfoundation/darwin/video_player_avfoundation")
    ],
    targets: [
        .testTarget(
            name: "FlutterPluginTest",
            dependencies: [
                "FlutterGeneratedPluginSwiftPackage",
                .product(name: "video_player_avfoundation_test", package: "video_player_avfoundation")
            ]
        )
    ]
)
