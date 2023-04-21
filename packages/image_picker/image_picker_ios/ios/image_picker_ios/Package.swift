// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "image_picker_ios",
    products: [
        .library(name: "image_picker_ios", targets: ["ImagePicker"]),
    ],
    dependencies: [
        .package(url: "https://github.com/erikdoe/ocmock.git", revision: "afd2c6924e8a36cb872bc475248b978f743c6050"),
        .package(name: "FlutterFramework", path: "/Users/vashworth/Development/flutter/bin/cache/artifacts/engine/ios"),
    ],
    targets: [
        .target(
            name: "ImagePicker",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
            ],
            cSettings: [
                .headerSearchPath("../../Classes"),
                .headerSearchPath("../../Classes/image_picker_ios"),
            ]
        ),
        .testTarget(
            name: "ImagePickerTest",
            dependencies: [
                "ImagePicker",
                .product(name: "OCMock", package: "ocmock"),
            ],
            resources: [
                .process("Assets/TestImages/")
            ],
            cSettings: [
                .headerSearchPath("../../Classes"),
                .headerSearchPath("../../Classes/image_picker_ios"),
            ]
        ),

    ]
)

// xcodebuild -scheme image_picker_ios -destination "platform=iOS Simulator,name=iPhone 14 Pro,OS=latest" test -sdk iphonesimulator
