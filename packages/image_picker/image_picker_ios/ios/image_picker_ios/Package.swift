// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "image_picker_ios",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "image_picker_ios",
            targets: ["image_picker_ios",]),
        .library(
            name: "image_picker_ios_test",
            targets: ["image_picker_ios_test",]),
    ],
    dependencies: [
        .package(url: "https://github.com/erikdoe/ocmock", revision: "afd2c6924e8a36cb872bc475248b978f743c6050") // 3.9.1
    ],
    targets: [
        .target(
            name: "image_picker_ios",
            dependencies: [],
            exclude: ["ImagePickerPlugin.modulemap", "image_picker_ios-umbrella.h"],
            cSettings: [
                .headerSearchPath("include/image_picker_ios"),
            ]
        ),
        .target(
           name: "image_picker_ios_test",
           dependencies: [
            .product(name: "OCMock", package: "OCMock")
           ],
           path: "Sources",
           sources: ["image_picker_ios_test"],
           publicHeadersPath: "image_picker_ios"
       ),
    ]
)
