// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "fingerprint_flutter",
    platforms: [
        .iOS("15.0"),
        .tvOS("15.0")
    ],
    products: [
        .library(name: "fingerprint_flutter", targets: ["fingerprint_flutter"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/fingerprintjs/fingerprint-ios", .upToNextMajor(from: "4.0.0"))
    ],
    targets: [
        .target(
            name: "fingerprint_flutter",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "Fingerprint", package: "fingerprint-ios")
            ]
        )
    ]
)
