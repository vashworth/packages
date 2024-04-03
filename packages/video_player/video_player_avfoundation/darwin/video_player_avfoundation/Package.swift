// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let pluginMinimumIOSVersion = Version("12.0.0")
let pluginMinimumMacOSVersion = Version("10.14.0")

let package = Package(
    name: "video_player_avfoundation",
    platforms: [
        flutterMinimumIOSVersion(pluginTargetVersion: pluginMinimumIOSVersion),
        flutterMinimumMacOSVersion(pluginTargetVersion: pluginMinimumMacOSVersion)
    ],
    products: [
        .library(name: "video_player_avfoundation", targets: ["video_player_avfoundation"]),
        .library(name: "video_player_avfoundation_test", targets: ["video_player_avfoundation_test"])
    ],
    dependencies: [
        flutterFrameworkDependency(),
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
                .product(name: "Flutter", package: "Flutter"),
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
