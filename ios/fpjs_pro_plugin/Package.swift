// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "fpjs_pro_plugin",
    platforms: [
        .iOS("15.0"),
        .tvOS("15.0")
    ],
    products: [
        .library(name: "fpjs-pro-plugin", targets: ["fpjs_pro_plugin"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        // Patch releases only. A minor that shipped with a problem cannot be
        // pulled from users once a floating range allows it. Take each minor
        // on purpose. Example: 2.8.0 caused App Store rejections.
        // https://github.com/fingerprintjs/fingerprintjs-pro-flutter/issues/92
        .package(url: "https://github.com/fingerprintjs/fingerprint-ios", .upToNextMinor(from: "4.0.0"))
    ],
    targets: [
        .target(
            name: "fpjs_pro_plugin",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "Fingerprint", package: "fingerprint-ios")
            ]
        )
    ]
)
