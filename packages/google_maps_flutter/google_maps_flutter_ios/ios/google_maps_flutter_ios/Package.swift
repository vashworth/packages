// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let pluginMinimumIOSVersion = Version("14.0.0")
let pluginMinimumMacOSVersion = Version("10.14.0")

let package = Package(
    name: "google_maps_flutter_ios",
    platforms: [
        flutterMinimumIOSVersion(pluginTargetVersion: pluginMinimumIOSVersion),
        flutterMinimumMacOSVersion(pluginTargetVersion: pluginMinimumMacOSVersion)
    ],
    products: [
        .library(name: "google_maps_flutter_ios", type: .static, targets: ["google_maps_flutter_ios"]),
        .library(name: "google_maps_flutter_ios_test", targets: ["google_maps_flutter_ios_test"])
    ],
    dependencies: [
        flutterFrameworkDependency(),
        .package(url: "https://github.com/googlemaps/ios-maps-sdk", "8.3.1"..<"9.0.0"),
        .package(url: "https://github.com/erikdoe/ocmock", revision: "ef21a2ece3ee092f8ed175417718bdd9b8eb7c9a") // v3.9.1
    ],
    targets: [
        .target(
            name: "google_maps_flutter_ios",
            dependencies: [
                .product(name: "Flutter", package: "Flutter"),
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


/// Returns the Package.Dependency for the Flutter framework.
///
/// Do not edit or remove. Used by the Flutter CLI to ensure the correct framework is used.
///
/// - Parameters:
///   - localFrameworkPath: The path to the Flutter framework Swift Package. Can be used when
///     locally developing the package. Will not be used when ran with the Flutter CLI.
/// - Returns: A Package.Dependency for the Flutter framework.
func flutterFrameworkDependency(localFrameworkPath: String? = nil) -> Package.Dependency {
   let flutterFrameworkPackagePath = localFrameworkPath ?? "unknown"
   return .package(name: "Flutter", path: flutterFrameworkPackagePath)
}

/// Returns the SupportedPlatform for iOS, ensuring the minimum deployment target version for the
/// iOS platform is always greater than or equal to that of the Flutter framework.
///
/// Do not edit or remove. Used by the Flutter CLI to ensure the correct minimum deployment target
/// version for iOS is used.
///
/// - Parameters:
///   - pluginTargetVersion: The minimum deployment target version for iOS.
/// - Returns: The SupportedPlatform for iOS.
func flutterMinimumIOSVersion(pluginTargetVersion: Version) -> SupportedPlatform {
   let iosFlutterMinimumVersion = Version("12.0.0")
   var versionString = pluginTargetVersion.description
   if iosFlutterMinimumVersion > pluginTargetVersion {
       versionString = iosFlutterMinimumVersion.description
   }
   return SupportedPlatform.iOS(versionString)
}

/// Returns the SupportedPlatform for macOS, ensuring the minimum deployment target version for the
/// macOS platform is always greater than or equal to that of the Flutter framework.
///
/// Do not edit or remove. Used by the Flutter CLI to ensure the correct minimum deployment target
/// version for macOS is used.
///
/// - Parameters:
///   - pluginTargetVersion: The minimum deployment target version for macOS.
/// - Returns: The SupportedPlatform for macOS.
func flutterMinimumMacOSVersion(pluginTargetVersion: Version) -> SupportedPlatform {
   let macosFlutterMinimumVersion = Version("10.14.0")
   var versionString = pluginTargetVersion.description
   if macosFlutterMinimumVersion > pluginTargetVersion {
       versionString = macosFlutterMinimumVersion.description
   }
   return SupportedPlatform.macOS(versionString)
}
