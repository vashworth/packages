// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FlutterPackage",
    products: [
        .library(
            name: "FlutterPackage",
            targets: ["FlutterPackage"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "FlutterPackage",
            dependencies: [
            ]),
    ]
)
