// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "image_picker_ios",
    platforms: [
        .iOS("12.0"),
        .macOS("10.14")
    ],
    products: [
        .library(name: "image_picker_ios", targets: ["image_picker_ios"]),
        .library(name: "image_picker_ios_test", targets: ["image_picker_ios_test"])
    ],
    dependencies: [
        .package(url: "https://github.com/erikdoe/ocmock", revision: "ef21a2ece3ee092f8ed175417718bdd9b8eb7c9a") // v3.9.1
    ],
    targets: [
        .target(
            name: "image_picker_ios",
            dependencies: [],
            exclude: ["ImagePickerPlugin.modulemap", "image_picker_ios-umbrella.h"],
            resources: [
                .process("Resources")
            ],
            cSettings: [
                .headerSearchPath("include/image_picker_ios")
            ]
        ),
        .target(
            name: "image_picker_ios_test",
            dependencies: [
                "image_picker_ios",
                .product(name: "OCMock", package: "OCMock")
            ],
            resources: [
               .process("Resources"),
            ],
            cSettings: [
                .headerSearchPath("../image_picker_ios"),
            ]
        )
    ]
)
