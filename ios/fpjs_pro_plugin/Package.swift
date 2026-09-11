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
    // Flutter injects its framework through the generated build settings; first-party plugins
    // also omit a package dependency on it.
    dependencies: [
        .package(url: "https://github.com/fingerprintjs/fingerprint-ios", .upToNextMajor(from: "4.0.0"))
    ],
    targets: [
        .target(
            name: "fpjs_pro_plugin",
            dependencies: [
                .product(name: "Fingerprint", package: "fingerprint-ios")
            ]
        )
    ]
)
