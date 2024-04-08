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
        .library(name: "google-maps-flutter-ios", type: .static, targets: ["google_maps_flutter_ios"])
    ],
    dependencies: [
        .package(url: "https://github.com/googlemaps/ios-maps-sdk", "8.3.1"..<"9.0.0")
    ],
    targets: [
        .target(
            name: "google_maps_flutter_ios",
            dependencies: [
                .product(name: "GoogleMaps", package: "ios-maps-sdk"),
                .product(name: "GoogleMapsBase", package: "ios-maps-sdk"),
                .product(name: "GoogleMapsCore", package: "ios-maps-sdk")
            ],
            resources: [
                .process("Resources")
            ],
            cSettings: [
                .headerSearchPath("include/google_maps_flutter_ios")
            ]
        )
    ]
)
