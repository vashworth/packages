// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import PackageDescription

let package = Package(
  name: "camera_avfoundation",
  platforms: [
    .iOS("12.0")
  ],
  products: [
    .library(name: "camera-avfoundation", targets: ["camera_avfoundation"]),
    .library(name: "camera-avfoundation-test", targets: ["camera_avfoundation_test"])
  ],
  dependencies: [],
  targets: [
    .target(
      name: "camera_avfoundation",
      dependencies: [],
      exclude: ["CameraPlugin.modulemap", "camera_avfoundation-umbrella.h"],
      resources: [
        .process("PrivacyInfo.xcprivacy")
      ],
      cSettings: [
          .headerSearchPath("include/camera_avfoundation")
      ]
    ),
    .target(
      name: "camera_avfoundation_test",
      dependencies: ["camera_avfoundation"],
      cSettings: [
        .headerSearchPath("include/camera_avfoundation_test")
      ]
    )
  ]
)
