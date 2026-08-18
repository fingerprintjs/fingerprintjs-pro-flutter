// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "fpjs_pro_plugin",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "fpjs-pro-plugin", targets: ["fpjs_pro_plugin"])
    ],
    // No FlutterFramework dependency. The plugin template adds one, but that package is only
    // generated from Flutter 3.41, which would break 3.24-3.40. Flutter injects the framework
    // via build settings. First-party Flutter plugins omit it too.
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
