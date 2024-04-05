// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "camera_avfoundation",
    platforms: [
        .iOS("12.0"),
        .macOS("10.14")
    ],
    products: [
        .library(name: "camera_avfoundation", targets: ["camera_avfoundation"]),
        .library(name: "camera_avfoundation_test", targets: ["camera_avfoundation_test"])
    ],
    dependencies: [
        .package(url: "https://github.com/erikdoe/ocmock", revision: "ef21a2ece3ee092f8ed175417718bdd9b8eb7c9a") // v3.9.1
    ],
    targets: [
        .target(
            name: "camera_avfoundation",
            dependencies: [],
            exclude: ["CameraPlugin.modulemap", "camera_avfoundation-umbrella.h"],
            resources: [
                .process("Resources")
            ],
            cSettings: [
                .headerSearchPath("include/camera_avfoundation")
            ]
        ),
         .target(
            name: "camera_avfoundation_test",
            dependencies: [
                "camera_avfoundation",
                .product(name: "OCMock", package: "OCMock")
            ],
            cSettings: [
                .headerSearchPath("../camera_avfoundation"),
            ]
        )
    ]
)