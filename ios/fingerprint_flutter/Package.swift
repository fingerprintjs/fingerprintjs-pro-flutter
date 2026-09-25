// swift-tools-version: 6.0

// Swift package for the Flutter iOS plugin.
import PackageDescription

let package = Package(
    name: "fingerprint_flutter",
    platforms: [
        .iOS("15.0"),
        .tvOS("15.0")
    ],
    products: [
        // Flutter generates this name for the native build by replacing `_` with `-`.
        // Flutter apps do not reference it. They depend on `fingerprint_flutter`.
        // https://github.com/flutter/flutter/blob/3.47.5/packages/flutter_tools/lib/src/commands/build_swift_package.dart#L1143-L1147
        .library(name: "fingerprint-flutter", targets: ["fingerprint_flutter"])
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
