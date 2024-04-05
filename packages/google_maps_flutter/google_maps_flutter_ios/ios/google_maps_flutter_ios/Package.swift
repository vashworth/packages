// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "google_maps_flutter_ios",
    platforms: [
        .iOS("14.0"),
        .macOS("10.14")
    ],
    products: [
        .library(name: "google_maps_flutter_ios", type: .static, targets: ["google_maps_flutter_ios"]),
        .library(name: "google_maps_flutter_ios_test", targets: ["google_maps_flutter_ios_test"])
    ],
    dependencies: [
        .package(url: "https://github.com/googlemaps/ios-maps-sdk", "8.3.1"..<"9.0.0"),
        .package(url: "https://github.com/erikdoe/ocmock", revision: "ef21a2ece3ee092f8ed175417718bdd9b8eb7c9a") // v3.9.1
    ],
    targets: [
        .target(
            name: "google_maps_flutter_ios",
            dependencies: [
                .product(name: "GoogleMaps", package: "ios-maps-sdk"),
                .product(name: "GoogleMapsBase", package: "ios-maps-sdk"),
                .product(name: "GoogleMapsCore", package: "ios-maps-sdk")
            ],
            exclude: ["google_maps_flutter_ios.modulemap", "google_maps_flutter_ios-umbrella.h"],
            resources: [
                .process("Resources")
            ],
            cSettings: [
                .headerSearchPath("include/google_maps_flutter_ios")
            ]
        ),
        .target(
            name: "google_maps_flutter_ios_test",
            dependencies: [
                "google_maps_flutter_ios",
                .product(name: "OCMock", package: "OCMock")
            ],
            cSettings: [
                .headerSearchPath("../google_maps_flutter_ios")
            ]
        )
    ]
)
