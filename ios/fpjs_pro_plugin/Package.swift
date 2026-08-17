// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "fpjs_pro_plugin",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "fpjs-pro-plugin", targets: ["fpjs_pro_plugin"])
    ],
    // No FlutterFramework dependency on purpose. Flutter's current plugin template declares one, but
    // the package it points at is only generated from Flutter 3.41 onwards, which would break SwiftPM
    // builds on 3.24-3.40. Flutter's own first-party plugins still omit it, so the Flutter framework
    // comes from the build settings the tool injects instead.
    dependencies: [
        .package(url: "https://github.com/fingerprintjs/fingerprintjs-pro-ios", .upToNextMinor(from: "2.17.0"))
    ],
    targets: [
        .target(
            name: "fpjs_pro_plugin",
            dependencies: [
                .product(name: "FingerprintPro", package: "fingerprintjs-pro-ios")
            ]
        )
    ]
)
