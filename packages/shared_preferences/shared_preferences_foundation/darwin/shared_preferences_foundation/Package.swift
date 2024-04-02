// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let pluginMinimumIOSVersion = Version("12.0.0")
let pluginMinimumMacOSVersion = Version("10.14.0")

let package = Package(
    name: "shared_preferences_foundation",
    platforms: [
        flutterMinimumIOSVersion(pluginTargetVersion: pluginMinimumIOSVersion),
        flutterMinimumMacOSVersion(pluginTargetVersion: pluginMinimumMacOSVersion)
    ],
    products: [
        .library(name: "shared_preferences_foundation", targets: ["shared_preferences_foundation"]),
        .library(name: "shared_preferences_foundation_test", targets: ["shared_preferences_foundation_test"])
    ],
    dependencies: [
        flutterFrameworkDependency()
    ],
    targets: [
        .target(
            name: "shared_preferences_foundation",
            dependencies: [
                .product(name: "Flutter", package: "Flutter")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "shared_preferences_foundation_test",
            dependencies: [
                "shared_preferences_foundation",
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
