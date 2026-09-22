// swift-tools-version: 6.0

// Host `swift test` cannot import Fingerprint (iOS/tvOS xcframework only).
// Plugin Package.swift also needs FlutterFramework, which Flutter generates
// and is not in the repo. JSONTypeConvertor.swift is a symlink so SPM stays
// inside this package root while still compiling the production file.
// https://docs.fingerprint.com/docs/tagging-information

import PackageDescription

let package = Package(
    name: "JSONTypeConvertorTests",
    platforms: [
        .iOS("15.0"),
        .tvOS("15.0")
    ],
    dependencies: [
        .package(url: "https://github.com/fingerprintjs/fingerprint-ios", .upToNextMajor(from: "4.0.0"))
    ],
    targets: [
        .testTarget(
            name: "JSONTypeConvertorTests",
            dependencies: [
                .product(name: "Fingerprint", package: "fingerprint-ios")
            ]
        )
    ]
)
