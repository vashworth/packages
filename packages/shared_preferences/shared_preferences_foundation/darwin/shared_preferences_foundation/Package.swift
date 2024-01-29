// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "shared_preferences_foundation",
    platforms: [
        .iOS("12.0"),
        .macOS("10.14")
    ],
    products: [
        .library(name: "shared_preferences_foundation", targets: ["shared_preferences_foundation"]),
        .library(name: "shared_preferences_foundation_test", targets: ["shared_preferences_foundation_test"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "shared_preferences_foundation",
            dependencies: [],
            resources: [
                .process("Resources"),
            ]
        ),
        .target(
            name: "shared_preferences_foundation_test",
            dependencies: [
                "shared_preferences_foundation",
            ],
            resources: [
               .process("Resources"),
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
