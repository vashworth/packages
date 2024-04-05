// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "video_player_avfoundation",
    platforms: [
        .iOS("12.0"),
        .macOS("10.14")
    ],
    products: [
        .library(name: "video_player_avfoundation", targets: ["video_player_avfoundation"]),
        .library(name: "video_player_avfoundation_test", targets: ["video_player_avfoundation_test"])
    ],
    dependencies: [
        .package(url: "https://github.com/erikdoe/ocmock", revision: "ef21a2ece3ee092f8ed175417718bdd9b8eb7c9a") // v3.9.1
    ],
    targets: [
        .target(
            name: "video_player_avfoundation_ios",
            cSettings: [
                .headerSearchPath("../video_player_avfoundation")
            ]
        ),
        .target(
            name: "video_player_avfoundation_macos",
            cSettings: [
                .headerSearchPath("../video_player_avfoundation")
            ]
        ),
        .target(
            name: "video_player_avfoundation",
            dependencies: [
                .target(name: "video_player_avfoundation_ios", condition: .when(platforms: [.iOS])),
                .target(name: "video_player_avfoundation_macos", condition: .when(platforms: [.macOS]))
            ],
            resources: [
                .process("Resources")
            ],
            cSettings: [
                .headerSearchPath("include/video_player_avfoundation")
            ]
        ),
        .target(
            name: "video_player_avfoundation_test",
            dependencies: [
                "video_player_avfoundation",
                .product(name: "OCMock", package: "OCMock")
            ],
            cSettings: [
                .headerSearchPath("../video_player_avfoundation"),
            ]
        )
    ]
)
