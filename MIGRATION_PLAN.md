# Flutter SDK 5.0.0 migration plan

Epic [INTER-2212](https://fingerprintjs.atlassian.net/browse/INTER-2212).
Tickets do not map one to one onto PRs.

Every PR targets `v5`. PR 10 merges `v5` into `main`. Nothing ships from
`main` in between: the native v4 upgrade renames `requestId` to `eventId`,
which breaks the shared Dart response type.

Decided: adopt Pigeon, keep the web implementation in the same package.

| # | PR | Tickets | Status |
|---|---|---|---|
| 1 | Requirements and native agent deps ([#147](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/pull/147)) | [INTER-2401](https://fingerprintjs.atlassian.net/browse/INTER-2401) | Open, CI green |
| 2 | Built-in Kotlin migration | [INTER-2398](https://fingerprintjs.atlassian.net/browse/INTER-2398) | To do |
| 3 | Platform interface | [INTER-2318](https://fingerprintjs.atlassian.net/browse/INTER-2318) | To do |
| 4 | Pigeon channel and flat response | [INTER-2320](https://fingerprintjs.atlassian.net/browse/INTER-2320), [INTER-2396](https://fingerprintjs.atlassian.net/browse/INTER-2396), [INTER-2386](https://fingerprintjs.atlassian.net/browse/INTER-2386), [INTER-2387](https://fingerprintjs.atlassian.net/browse/INTER-2387) | To do |
| 5 | Error model | none | To do |
| 6 | Public Dart API | [INTER-2318](https://fingerprintjs.atlassian.net/browse/INTER-2318) | To do |
| 7 | Web interop for agent v4 | [INTER-2319](https://fingerprintjs.atlassian.net/browse/INTER-2319) | To do |
| 8 | Rename repo and package | [INTER-2400](https://fingerprintjs.atlassian.net/browse/INTER-2400) | To do |
| 9 | Docs, migration guide, example app | none | To do |
| 10 | Release 5.0.0 | none | To do |

[INTER-2321](https://fingerprintjs.atlassian.net/browse/INTER-2321) (Swift
Package Manager) shipped in 4.13.0.

PRs 5, 9 and 10 have no ticket. The error model is the largest of the three:
32 classes and a 56-case switch.

## PR 1. Requirements and native agent deps

[#147](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/pull/147),
open, CI green. [INTER-2401](https://fingerprintjs.atlassian.net/browse/INTER-2401).

Floor at Flutter 3.44, Dart 3.12, Android API 24, iOS and tvOS 15, Xcode 16,
Swift 6, Gradle 8.13, AGP 8.13.2, Kotlin 2.3.20, Java 11, compileSdk 36.
Android on `com.fingerprint.android:sdk:4.0.0` pinned exact, iOS on
`Fingerprint-iOS` and `fingerprint-ios`. Pigeon 28.1.0 pinned. Major
changeset added. Native code changed only enough to compile.

Kotlin 2.3.20 compiles without `-Xskip-metadata-version-check`. React Native
needed that flag for the same Android SDK. This was the largest open risk.

Two follow-ups:

- Android error codes come from `error.javaClass.simpleName`. R8 renames
  classes, so codes are correct in debug and wrong in minified release
  builds. Restore an explicit mapping or add a keep rule.
- Tuple index 0 is named `requestId` and carries `eventId`. Index 1 is named
  `confidenceScore` and carries `suspectScore`. PR 4 removes the tuple.

## PR 2. Built-in Kotlin migration

[INTER-2398](https://fingerprintjs.atlassian.net/browse/INTER-2398), GitHub
issue [#117](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/issues/117).

AGP 9.0 drops support for plugins that apply the Kotlin Gradle Plugin.
`android/settings.gradle` still applies it. Follow Flutter's built-in Kotlin
guide for plugin authors.

Android build files only. Land early, before the Kotlin package path changes
in PR 8.

## PR 3. Platform interface

[INTER-2318](https://fingerprintjs.atlassian.net/browse/INTER-2318), partial.

Add `plugin_platform_interface`, `FingerprintPlatform`,
`MethodChannelFingerprint`, `FingerprintWeb`. Public API unchanged.

Removes the web round trip, where Dart calls `invokeMethod` and the web
plugin answers it in the same process. Tests switch to replacing
`FingerprintPlatform.instance`.

Before Pigeon, so the generated code sits inside `MethodChannelFingerprint`.

## PR 4. Pigeon channel and flat response

[INTER-2320](https://fingerprintjs.atlassian.net/browse/INTER-2320),
[INTER-2396](https://fingerprintjs.atlassian.net/browse/INTER-2396),
[INTER-2386](https://fingerprintjs.atlassian.net/browse/INTER-2386),
[INTER-2387](https://fingerprintjs.atlassian.net/browse/INTER-2387).

Generate the Dart, Kotlin and Swift message classes. Delete the positional
tuple. Flat response: `eventId`, `visitorId`, `suspectScore`, `sealedResult`.
Delete the extended response type, `ConfidenceScore`, `IpLocation`,
`StSeenAt`, `extendedResponseFormat`.

One PR, because the tuple is what carries the mismatched names.

Stateless per call: every get message includes the full config, native keeps
no client between calls. Two Dart clients with different configs stay
independent.

Also fix: `ipAddress` and `osName` accept two key spellings
(`json['ip'] ?? json['ipAddress']`); `sealedResult` is typed `String?` but
both platforms send an empty string.

[INTER-2386](https://fingerprintjs.atlassian.net/browse/INTER-2386) and
[INTER-2387](https://fingerprintjs.atlassian.net/browse/INTER-2387) duplicate
[INTER-2320](https://fingerprintjs.atlassian.net/browse/INTER-2320) and
[INTER-2396](https://fingerprintjs.atlassian.net/browse/INTER-2396). They sit
outside the epic, are assigned to Ilya, and cover React Native too. No link
connects the pairs. Close or link before starting.

## PR 5. Error model

No ticket.

One `FingerprintError implements Exception` with `code` (enum), `rawCode`,
`message`, `eventId`. Replaces 32 classes and the 56-case `unwrapError`
switch.

`implements`, not `extends`. `FingerprintProError` extends
`PlatformException` today, which on web describes a failure that never
happened.

`eventId` is on the React Native error and missing from the proposal. Use the
same snake_case wire codes as React Native.

Replaces PR 1's reflection-based Android mapping if it survived.

After Pigeon: the error payload crosses the channel.

## PR 6. Public Dart API

[INTER-2318](https://fingerprintjs.atlassian.net/browse/INTER-2318), closes.

`Fingerprint` class, config in the constructor. `AndroidOptions`,
`IosOptions`, `WebOptions` nested under shared options. One `endpoints` list.
`Duration` timeouts. `get({tags, linkedId, timeout})`.

A Dart constructor cannot await. Stateless per call from PR 4 is what removes
the initialization step and the "not initialized" error.

Decide `tags`: `Map<String, dynamic>?` today, the agent takes any JSON value,
React Native takes a string, number, boolean or object.

First `5.0.0-alpha` if changesets prerelease mode can push to pub.

## PR 7. Web interop for agent v4

[INTER-2319](https://fingerprintjs.atlassian.net/browse/INTER-2319).

Rewrite `js_agent_interop.dart` for the v4 start function. Remove
`extendedResult` and `scriptUrlPattern`.

Add `urlHashing`, `storageKeyPrefix`, `cacheHit`, and cache with the
`optimize-cost` and `aggressive` presets as a sealed `CacheDuration`, not a
bare `Duration`.

Add the Dart equivalent of React Native's `agentCompatibility` test, which
fails the build when web option keys drift from the agent's.

## PR 8. Rename repo and package

[INTER-2400](https://fingerprintjs.atlassian.net/browse/INTER-2400).

Repo to `flutter`, package to `fingerprint_flutter`, `FpjsProPlugin` to
`Fingerprint`. The upstream repo is not renamed yet, so this covers both.

Mechanical: package name, library file, podspec, `Package.swift`, Kotlin
package path, example app, changesets config, `scripts/update_version.sh`,
CI workflow.

Last, so imports are rewritten once.

Two consumer costs, documented in PR 9. A new pub name is a new package:
score, likes and downloads start at zero, and `fpjs_pro_plugin` needs marking
discontinued. The path `assets/packages/fpjs_pro_plugin/web/index.js` is in
every web consumer's `index.html`; check whether it can stay.

## PR 9. Docs, migration guide, example app

No ticket. The web asset path is a numbered migration step, not a footnote.

## PR 10. Release 5.0.0

No ticket. Merge `v5` into `main`. The major changeset exists from PR 1. The
package is at 4.13.0.

## What each PR proves

CI builds the example app on Android, iOS and web every time. Beyond that:

- PR 2: Android builds against an AGP 9 preview with no Kotlin Gradle Plugin
  warning.
- PR 3: tests pass after replacing `FingerprintPlatform.instance`.
- PR 4: the example app shows a real `eventId` and `suspectScore` on both
  platforms; no positional tuple in Dart, Kotlin or Swift.
- PR 5: every former error class has a covering enum case; codes survive a
  minified release build.
- PR 7: web option keys match the agent, checked at compile time.
