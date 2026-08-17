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
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/fingerprintjs/fingerprintjs-pro-ios", .upToNextMinor(from: "2.17.0"))
    ],
    targets: [
        .target(
            name: "fpjs_pro_plugin",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "FingerprintPro", package: "fingerprintjs-pro-ios")
            ]
        )
    ]
)
