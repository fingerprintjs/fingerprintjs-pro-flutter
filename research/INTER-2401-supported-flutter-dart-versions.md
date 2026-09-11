# INTER-2401: Flutter and Dart support for the v4-agent release

Date: 2026-09-11

## Decision

For the Flutter package `5.0.0` release that adopts the v4 JavaScript, iOS,
and Android agents, use one public and maintainer floor:

```yaml
environment:
  sdk: ">=3.12.0 <4.0.0"
  flutter: ">=3.44.0"
```

This assumes we adopt and pin current Pigeon `28.1.0` as a dev dependency.
Pigeon declares Dart `^3.11.0`, but Flutter `3.41.0` cannot resolve it because
that Flutter SDK pins `meta 1.17.0` while Pigeon's analyzer requires a newer
`meta`. Flutter `3.44.0` / Dart `3.12.0` resolves Pigeon 28.1.0 successfully,
so it is the smallest empirically verified floor after updating dependencies.

The generated Dart from Pigeon 28.1.0 was also analyzed successfully on
Flutter 3.19 / Dart 3.3. We deliberately reject that separated-policy option:
the latest common Flutter dependency ecosystem now expects newer SDKs, and one
public floor is simpler to document, test, and support.

The resulting platform promise is Android API 24 and iOS/tvOS 15. Android v4
itself supports API 23, but Flutter 3.44's supported/default Android floor is
API 24; the iOS v4 build requirement is Xcode 16 / Swift 6, whose iOS
deployment targets start at 15.

This does **not** make the native migration optional. The platform/runtime and
host-build changes in the Native v4 requirements section are mandatory changes
to this plugin; the Flutter/Dart floor is a separate consumer-tooling promise.

## Options considered

"Without Pigeon" means that the v5 implementation uses hand-written platform
channels (or another generator) and Pigeon is not in the resolved dependency
graph. It does not undo a native v4 requirement. The numbers below are the
simple, **one-floor policy**: the minimum supported by both package consumers
and package contributors. Since Pigeon is a `dev_dependency`, a team could
instead generate on Flutter 3.44 and publish a lower consumer floor only after
testing the generated sources there.

| Requirement | Current published support | v5 maintainer / codegen | v5 public consumer | One shared floor, no Pigeon | Why / source |
| --- | --- | --- | --- | --- | --- |
| Flutter | 3.19.0 | **3.44.0** | **3.19.0** | **3.32.0** | Pigeon 28.1 resolves at 3.44/3.12, but its dev dependency is ignored for consumers. Without Pigeon, latest `flutter_lints` 6 sets the one-project floor. [Dart Pub](https://dart.dev/tools/pub/dependencies#dev-dependencies), [Pigeon](https://pub.dev/packages/pigeon/changelog) |
| Dart | 3.3.0 | **3.12.0** | **3.3.0** | **3.8.0** | Pigeon output was analyzed at 3.3; Dart 3.12 is only needed to run the current generator. [Flutter archive](https://docs.flutter.dev/install/archive) |
| Android runtime | API 23 / Android 6 | n/a | **API 23 / Android 6** | **API 23 / Android 6** | Android v4 AAR requires minSdk 23. Flutter 3.44's default minSdk 24 is irrelevant when the public consumer floor remains Flutter 3.19 and the wrapper sets 23. [Android v4 notes](https://app.notion.com/p/3a502f125ebd80e7bfb1c0473405ddf8) |
| Android build host | Not stated publicly | v4 SDK producer: API 36, AGP 8.13.2, Kotlin 2.3.20, Gradle 8.13, JDK 17 | Test actual wrapper at Flutter 3.19; do not advertise producer versions as app requirements | Same | The v4 AAR POM has no Gradle/Kotlin/AGP dependency. [Android v4 AAR POM](https://github.com/fingerprintjs/fingerprintjs-pro-android/releases/download/v4.0.0/sdk-4.0.0.pom) |
| iOS runtime | iOS 13 / tvOS 15 | n/a | **iOS 15 / tvOS 15** | **iOS 15 / tvOS 15** | The native package declares iOS 14, but v4's Xcode 16 requirement makes iOS 15 the supportable deployment target. [iOS v4 notes](https://app.notion.com/p/3a602f125ebd80008b2cf89c0781ad54), [Xcode requirements](https://developer.apple.com/xcode/system-requirements) |
| Apple build host | Swift 5.9 | **Xcode 16+, Swift 6** | **Xcode 16+, Swift 6** | **Xcode 16+, Swift 6** | Required by the iOS v4 package/build integration, independent of Pigeon. [iOS v4 notes](https://app.notion.com/p/3a602f125ebd80008b2cf89c0781ad54) |

## Why this is a major release

[INTER-2401](https://fingerprintjs.atlassian.net/browse/INTER-2401) asks us to
identify the supported Dart/Flutter floor from customer expectations and the
ecosystem, update dependencies, and reflect the result in the README. Its
parent, [INTER-2212](https://fingerprintjs.atlassian.net/browse/INTER-2212), is
the migration to the v4 JavaScript, iOS, and Android agents.

The [Flutter v4 API proposal](https://app.notion.com/p/3b902f125ebd80c7bfd7fd0db7505de6)
is a draft, and explicitly leaves both the minimum SDK version and adoption of
Pigeon open. It proposes package version `5.0.0`, because the existing package
is already at major version 4. The planned API is breaking regardless: an
instance `Fingerprint` client replaces global static state, results are flat,
`requestId` becomes `eventId`, the extended-result flag disappears, and errors
become one exception type plus an enum.

## Dependency result

These are the latest Pub package manifests checked on 2026-09-11.

| Dependency | Latest | Declared Dart minimum | Effect |
| --- | ---: | ---: | --- |
| [pigeon](https://pub.dev/packages/pigeon/versions) | 28.1.0 | 3.11 | Sets the floor when adopted. Version 28 also changes generated Swift/Kotlin async APIs, so pin the exact generator version and commit generated sources. |
| [flutter_lints](https://pub.dev/packages/flutter_lints/versions) | 6.0.0 | 3.8 | Below the Pigeon floor. |
| [geolocator](https://pub.dev/packages/geolocator/versions) | 14.0.3 | 3.5 | Example-only dependency; below the Pigeon floor. |
| [cupertino_icons](https://pub.dev/packages/cupertino_icons/versions) | 1.0.9 | 3.9 | Example-only dependency; below the Pigeon floor. |
| [env_flutter](https://pub.dev/packages/env_flutter/versions) | 0.1.4 | `<3.0` | Cannot be upgraded into a Dart 3 project. Replace it, remove it, or use a maintained fork. |

The root and example are configured for Dart `>=3.12.0` and Flutter
`>=3.44.0`; the CI floor matrix and README match. `flutter_lints` is upgraded
to `^6.0.0`, and the example uses `geolocator ^14.0.3` and
resolves `cupertino_icons 1.0.9`. `env_flutter ^0.1.4` remains because it has no
newer Pub release; it should still be replaced or removed during v5 work.

Flutter `3.44.0` / Dart `3.12.0` was installed locally outside this repository.
`flutter pub upgrade --major-versions`, `flutter analyze`, and `flutter test`
all succeed at that floor. Pigeon `28.1.0` is installed as an exact dev
dependency and resolves at that floor; no Pigeon schema or generated channel
sources exist yet.

## Native v4 requirements

| Area | v4 requirement | Required repository change |
| --- | --- | --- |
| Android runtime | Native agent: Android 6.0, API 23; v5 wrapper: Android 7.0, API 24 | Raise plugin `minSdk` from 21 to 24. The v4 AAR manifest itself declares 23. |
| Android build | The v4 SDK producer uses API 36, Kotlin 2.3.20, AGP 8.13, Gradle 8.13, JDK 17, JVM target 11 | Do not automatically require these versions of consuming apps: the AAR metadata has `minCompileSdk=1` and `minAndroidGradlePluginVersion=1.0.0`. Build the actual wrapper with the oldest supported Flutter/app toolchain and latest stable instead. |
| iOS runtime | Native agent: iOS 14, tvOS 15; wrapper/App Store build: iOS 15, tvOS 15 | Raise the iOS deployment target from iOS 13 to 15. Xcode 16's supported iOS deployment targets begin at 15, so iOS 14 cannot be a supported wrapper promise despite the native XCFramework declaring it. |
| iOS build | Xcode 16+, Swift 6 | Update the native wrapper and test on Xcode 16+. Change the SPM package from `fingerprintjs/fingerprintjs-pro-ios` to `fingerprintjs/fingerprint-ios`; change the CocoaPods pod from `FingerprintPro` to `Fingerprint-iOS`. |

The Android values come from the [Android v4 internal release notes](https://app.notion.com/p/3a502f125ebd80e7bfb1c0473405ddf8).
The iOS values come from the [iOS v4 internal release notes](https://app.notion.com/p/3a602f125ebd80008b2cf89c0781ad54);
the effective wrapper deployment floor follows [Xcode 16's supported targets](https://developer.apple.com/xcode/system-requirements).
The current repository instead pins Android/iOS agent 2.17.x, has Android
`minSdk 21`, `compileSdk 35`, Java/Kotlin target 1.8, and iOS 13.

The source/API migration is also required: both native SDKs rename their
factory/client and result types, rename `requestId` to `eventId`, remove
`extendedResponseFormat`, flatten the result, revise errors, and add
`suspectScore`. The Flutter v5 API proposal mirrors those breaking changes.

This dependency/floor change deliberately does not alter those native settings
yet: the repository still targets the v2.17 agents, so changing only
`minSdk`, the deployment target, or native package coordinates would produce a
partially migrated release. Apply the entire native row together when the v4
wrapper implementation lands.

## Empirical dependency checks

- Pigeon `28.1.0` is installed successfully with Flutter `3.44.0` / Dart
  `3.12.0`. It fails with Flutter `3.41.0` because that SDK pins `meta 1.17.0`
  below Pigeon's analyzer requirement. This verifies the selected Flutter/Dart
  floor, not just the Dart constraint written in Pigeon's pubspec.
- The iOS v4 package [`fingerprintjs/fingerprint-ios` at 4.0.0](https://github.com/fingerprintjs/fingerprint-ios/tree/4.0.0)
  resolved with Swift Package Manager and downloaded its XCFramework. Its
  manifest declares Swift tools 6.0, iOS 14, and tvOS 15.
- The Android v4 [GitHub release](https://github.com/fingerprintjs/fingerprintjs-pro-android/releases/tag/v4.0.0)
  provides `com.fingerprint.android:sdk:4.0.0` as an AAR plus POM. That
  coordinate resolved and assembled from a temporary local Maven repository
  using Gradle 8.13, AGP 8.13.2, Kotlin 2.3.20, JDK 17, API 36, and minSdk 23.
  A Kotlin smoke source compiled against the real public v4
  `FingerprintFactory` and `Configuration` APIs. This is compile integration,
  not an on-device/network test.

Flutter 3.44's Android template uses Kotlin 2.3.20, matching the SDK-producer
environment. That coincidence does not make it a consumer requirement; the
v4 integration still needs an example APK build at the supported public floor.

Xcode 16/Swift 6 does not independently require a higher Flutter floor.
Flutter 3.44 makes Swift Package Manager the default dependency manager.

## Ecosystem and adoption assessment

The maintainer recommendation—Flutter 3.44 / Dart 3.12 / Android SDK producer
tools at API 36 / iOS 15—is aligned with current platform and package
direction, but it does not by itself require a Flutter/Dart or Android runtime
lift for consumers.
There is no authoritative public telemetry for the Flutter/Dart versions used
by production applications, so it would be misleading to estimate a percentage
of customers blocked. Customer-side Play Console Reach and App Store Connect
analytics are the appropriate data for that decision.

The direct ecosystem sample is mixed rather than uniformly old: current
`go_router`, `sqflite`, and `camera` releases already require Flutter 3.44 /
Dart 3.12; `google_maps_flutter` requires Flutter 3.38 / Dart 3.10; and
`firebase_core` requires Flutter 3.27 / Dart 3.6. Lower inclusive package
minimums do not prevent apps from upgrading—the blockers are pinned CI/Flutter
SDKs or dependency upper bounds.

The Android SDK producer build requirement is also on the normal platform trajectory:
Google Play requires target API 36 for new apps and updates after 31 August
2026. iOS 15 does exclude legacy devices because Xcode 16 is required for the
iOS v4 integration; Android remains at its native API 23 floor. See [Flutter supported
platforms](https://docs.flutter.dev/reference/supported-platforms), [Google
Play target API requirements](https://developer.android.com/google/play/requirements/target-sdk),
[go_router](https://pub.dev/api/packages/go_router),
[sqflite](https://pub.dev/api/packages/sqflite),
[camera](https://pub.dev/api/packages/camera),
[google_maps_flutter](https://pub.dev/api/packages/google_maps_flutter), and
[firebase_core](https://pub.dev/api/packages/firebase_core).

Keeping Android API 23 is compatible with the separated policy. Keeping iOS
14 would require revisiting the native SDK's Xcode 16/Swift 6 requirement;
omitting Pigeon has no bearing on either platform floor.

## Community dependency sample

This is a **representative, not statistically ranked**, sample of 15 packages
that are broadly used in Flutter applications. It spans state management,
navigation, HTTP, Firebase, storage, device integration, mapping, and local
database access. The selection was checked against Pub's first-party package
and score APIs on 2026-09-11. The downloads and likes make the choice
auditable; Pub does not expose a documented, deterministic API for a global
`top 15 Flutter packages` ranking, so it would be incorrect to label these
the literal fifteen most-used packages.

"Public 3.19/3.3" means that the **latest release's declared direct SDK
constraints** accept Flutter 3.19.0 (which bundles Dart 3.3) and Dart 3.3.0.
It does not prove every transitive dependency or platform-specific build path.
"Maintainer 3.44/3.12" applies the same test to the Pigeon code-generation
environment. A package with no Flutter constraint is Dart-only at the Pub
manifest level; its compatibility assessment is limited to that declared
constraint.

| Area | Package (latest) | Latest Dart constraint | Latest Flutter constraint | 30-day downloads / likes | Public 3.19/3.3 | Maintainer 3.44/3.12 | Primary Pub metadata |
| --- | --- | --- | --- | ---: | --- | --- | --- |
| State | `provider` 6.1.5+1 | `>=2.12.0 <4.0.0` | `>=1.16.0` | 1,105,051 / 11,004 | Yes | Yes | [API](https://pub.dev/api/packages/provider), [score](https://pub.dev/api/packages/provider/score) |
| State | `flutter_riverpod` 3.4.3 | `^3.12.0` | `>=3.0.0` | 3,076,481 / 4,030 | No — Dart 3.12 | Yes | [API](https://pub.dev/api/packages/flutter_riverpod), [score](https://pub.dev/api/packages/flutter_riverpod/score) |
| State | `flutter_bloc` 9.1.1 | `>=2.14.0 <4.0.0` | none | 1,873,888 / 8,074 | Yes | Yes | [API](https://pub.dev/api/packages/flutter_bloc), [score](https://pub.dev/api/packages/flutter_bloc/score) |
| Navigation | `go_router` 18.0.1 | `^3.12.0` | `>=3.44.0` | 4,056,040 / 5,780 | No — Flutter 3.44, Dart 3.12 | Yes | [API](https://pub.dev/api/packages/go_router), [score](https://pub.dev/api/packages/go_router/score) |
| Networking | `dio` 5.11.1 | `>=2.18.0 <4.0.0` | none | 4,214,118 / 8,349 | Yes | Yes | [API](https://pub.dev/api/packages/dio), [score](https://pub.dev/api/packages/dio/score) |
| Networking | `http` 1.6.0 | `^3.4.0` | none | 11,561,531 / 8,472 | No — Dart 3.4 | Yes | [API](https://pub.dev/api/packages/http), [score](https://pub.dev/api/packages/http/score) |
| Firebase | `firebase_core` 4.14.0 | `^3.6.0` | `>=3.27.0` | 4,375,639 / 4,076 | No — Flutter 3.27, Dart 3.6 | Yes | [API](https://pub.dev/api/packages/firebase_core), [score](https://pub.dev/api/packages/firebase_core/score) |
| Firebase | `firebase_auth` 6.6.1 | `^3.6.0` | `>=3.16.0` | 1,578,911 / 4,293 | No — Dart 3.6 | Yes | [API](https://pub.dev/api/packages/firebase_auth), [score](https://pub.dev/api/packages/firebase_auth/score) |
| Storage | `shared_preferences` 2.5.5 | `^3.9.0` | `>=3.35.0` | 6,465,811 / 10,565 | No — Flutter 3.35, Dart 3.9 | Yes | [API](https://pub.dev/api/packages/shared_preferences), [score](https://pub.dev/api/packages/shared_preferences/score) |
| Device / OS | `url_launcher` 6.3.2 | `^3.6.0` | `>=3.27.0` | 6,444,248 / 8,173 | No — Flutter 3.27, Dart 3.6 | Yes | [API](https://pub.dev/api/packages/url_launcher), [score](https://pub.dev/api/packages/url_launcher/score) |
| Files | `path_provider` 2.1.6 | `^3.10.0` | `>=3.38.0` | 7,664,783 / 5,565 | No — Flutter 3.38, Dart 3.10 | Yes | [API](https://pub.dev/api/packages/path_provider), [score](https://pub.dev/api/packages/path_provider/score) |
| Media | `image_picker` 1.2.3 | `^3.10.0` | `>=3.38.0` | 4,252,822 / 7,762 | No — Flutter 3.38, Dart 3.10 | Yes | [API](https://pub.dev/api/packages/image_picker), [score](https://pub.dev/api/packages/image_picker/score) |
| Permissions | `permission_handler` 13.0.2 | `^3.6.0` | `>=3.24.0` | 3,261,842 / 6,011 | No — Flutter 3.24, Dart 3.6 | Yes | [API](https://pub.dev/api/packages/permission_handler), [score](https://pub.dev/api/packages/permission_handler/score) |
| Maps | `google_maps_flutter` 2.18.0 | `^3.10.0` | `>=3.38.0` | 906,506 / 4,628 | No — Flutter 3.38, Dart 3.10 | Yes | [API](https://pub.dev/api/packages/google_maps_flutter), [score](https://pub.dev/api/packages/google_maps_flutter/score) |
| Database | `sqflite` 2.4.4 | `^3.12.0` | `>=3.44.0` | 2,984,731 / 5,564 | No — Flutter 3.44, Dart 3.12 | Yes | [API](https://pub.dev/api/packages/sqflite), [score](https://pub.dev/api/packages/sqflite/score) |

Only 3 of the 15 latest releases (`provider`, `flutter_bloc`, and `dio`) accept
the public 3.19/3.3 floor as declared. The other 12 already require a newer
Flutter and/or Dart SDK; the highest in this sample is Flutter 3.44 / Dart
3.12 (`go_router`, `sqflite`). All 15 accept the proposed maintainer floor.
That is evidence that Flutter 3.44 / Dart 3.12 is aligned with the **current
latest-dependency** ecosystem, but it is not evidence that 3.19/3.3 customers
cannot use this SDK: those customers may retain compatible older dependency
versions, and our package's consumer constraints remain independently
resolvable. Conversely, a 3.19 app that insists on updating every direct
dependency to latest is normally already blocked by its other packages, before
adding this SDK.

For release positioning, retain the separated public 3.19/3.3 promise only if
the actual v4 wrapper is CI-tested there. Describe Flutter 3.44/Dart 3.12 as
the recommended/current-tooling baseline for apps that update their full
dependency graph, rather than overstating either result as universal adoption
data.

## Required validation before publishing the floor

1. Add a Pigeon schema, generate the channel sources with the pinned `28.1.0`
   generator, and commit them.
2. Update direct dependencies to the versions above; remove or replace
   `env_flutter`.
3. Run `flutter pub upgrade --major-versions` and `flutter analyze` with
   Flutter `3.44.0`.
4. On Flutter `3.19.0` and latest stable, build and run the Android example
   with the actual v4 wrapper, minSdk 23, and a supported app toolchain.
5. Build the iOS example with Xcode 16+, Swift 6, iOS deployment target 15,
   and both supported package managers if CocoaPods remains supported.
6. Keep a CI floor matrix for Flutter 3.44.0 and latest stable, and update the
   README requirements and migration guide in the same release.

Flutter 3.44's templates use Kotlin 2.3.20, which matches the Android v4
requirement. Step 4 is still needed to verify the native artifact itself.

## Separated public-floor validation

When Pigeon is used only to generate and commit sources, it is a maintainer
tool and is not resolved by an application's dependency graph. Therefore the
consumer floor is **not** automatically Pigeon's Dart floor. With all direct
dependencies here remaining development-only, the public package can retain
the existing **Flutter 3.19 / Dart 3.3** floor *if and only if* the committed
generated Dart, Kotlin, and Swift sources are tested on it. The earlier
Flutter 3.32 / Dart 3.8 number is a conservative one-project floor that lets
the publisher also run latest `flutter_lints` 6 in the same SDK environment;
it is not a demonstrated consumer requirement.

Empirical checks on 2026-09-11:

- Flutter **3.19.0 / Dart 3.3.0** and Flutter **3.32.0 / Dart 3.8.0** were
  installed from the official archives. The same Dart source generated by
  Pigeon 28.1.0 (`lib/messages.dart`) analyzed successfully on both using
  `flutter analyze lib`, with Pigeon deliberately absent from the fixture's
  `pubspec.yaml`. This establishes empirically that the generator's own Dart
  3.11 constraint does not describe the generated Dart API's minimum, and
  that Pigeon 28.1.0 output is source-compatible with the existing public
  Flutter/Dart floor for this message shape.
- A separate Flutter **3.19.0** consumer fixture depended on this package by
  path and ran `flutter pub get` and `flutter test` successfully. Its resolved
  graph contains `fpjs_pro_plugin` and Flutter SDK packages but not Pigeon,
  confirming Pub's dev-dependency isolation in this package's real consumer
  shape.
- A Flutter 3.32 Android consumer fixture was configured with the real v4 AAR
  `com.fingerprint.android:sdk:4.0.0`, API 36, minSdk 23, AGP 8.13.2, Kotlin
  2.3.20, Gradle 8.13, JDK 17, and a Kotlin source calling
  `FingerprintFactory(context).createInstance(Configuration("test-api-key"))`.
  Flutter 3.32's Gradle plugin compiled under that configuration (only an AGP
  deprecation warning), and `./gradlew :app:assembleDebug --no-daemon`
  completed successfully, producing both Android and Flutter debug APKs. This
  validates the real AAR, the imported v4 Kotlin APIs, and the requested
  consumer build matrix together.
- The Android v4 release [POM](https://github.com/fingerprintjs/fingerprintjs-pro-android/releases/download/v4.0.0/sdk-4.0.0.pom)
  has only group/artifact/version/`aar` packaging and declares no Gradle,
  Kotlin, or Android-plugin dependency. Thus its stated AGP/Kotlin versions
  are the **SDK producer** build requirements, not Maven-enforced constraints
  on Flutter application builds. The downloaded AAR's
  `aar-metadata.properties` additionally declares `minCompileSdk=1` and
  `minAndroidGradlePluginVersion=1.0.0`; its manifest declares only
  `minSdkVersion=23`.

Official Flutter 3.32 sources pair it with Dart 3.8 and default an Android
template to Gradle 8.12, AGP 8.7.3, Kotlin 2.1.0, compile/target SDK 35 and
minSdk 21; those settings are defaults rather than limits. Its generated app
template permits an app/plugin to configure a higher minSdk such as v4's 23.
See the [Flutter 3.32 release announcement](https://docs.flutter.dev/release/archive-whats-new#20-may-2025-google-io-release-332),
[Flutter 3.32 Gradle defaults](https://github.com/flutter/flutter/blob/3.32.0/packages/flutter_tools/lib/src/android/gradle_utils.dart#L32-L50),
and [Android SDK configuration guidance](https://docs.flutter.dev/deployment/android#android-sdk-versions).

**Decision implication:** a separated policy can retain **Flutter 3.19 / Dart
3.3** as the public floor. Add CI that builds the *actual* generated v4
wrapper at that floor and latest stable on Android and iOS before publishing
that promise; the current check proves generated Dart compatibility, not the
future schema or complete native wrapper. Flutter 3.44/Dart 3.12 remains the
maintainer/code-generation floor for Pigeon 28.1.0.

## Sources

- [Flutter v4 API Support Proposal](https://app.notion.com/p/3b902f125ebd80c7bfd7fd0db7505de6)
- [Android SDK v4 internal release notes](https://app.notion.com/p/3a502f125ebd80e7bfb1c0473405ddf8)
- [iOS SDK v4 internal release notes](https://app.notion.com/p/3a602f125ebd80008b2cf89c0781ad54)
- [Fingerprint iOS 4.0.0 package manifest](https://github.com/fingerprintjs/fingerprint-ios/blob/4.0.0/Package.swift)
- [Fingerprint Android 4.0.0 release assets](https://github.com/fingerprintjs/fingerprintjs-pro-android/releases/tag/v4.0.0)
- [Pigeon package metadata and changelog](https://pub.dev/packages/pigeon/changelog)
- [Flutter 3.44 release notes](https://docs.flutter.dev/release/release-notes/release-notes-3.44.0)
- [Flutter release archive](https://storage.googleapis.com/flutter_infra_release/releases/releases_macos.json)
- [Flutter supported deployment platforms](https://docs.flutter.dev/reference/supported-platforms)
- [Xcode SDK and system requirements](https://developer.apple.com/xcode/system-requirements)
- [Google Play target API requirements](https://developer.android.com/google/play/requirements/target-sdk)
- [Android Gradle Plugin 8.13 release notes](https://developer.android.com/build/releases/agp-8-13-0-release-notes)
- [Android Gradle JDK guidance](https://developer.android.com/build/jdks)
