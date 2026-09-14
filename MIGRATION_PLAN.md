# Flutter SDK 5.0.0 migration plan

Epic [INTER-2212](https://fingerprintjs.atlassian.net/browse/INTER-2212).
Tickets do not map one to one onto PRs.

Every v5 PR targets `v5`. PR 8 merges `v5` into `main`. Nothing ships from
`main` in between: the native v4 upgrade renames `requestId` to `eventId`,
which breaks the shared Dart response type.

Decided: adopt Pigeon, keep the web implementation in the same package.

## v5 directive

Use this major release as the one breaking-change window for the Flutter SDK.
Make the established structural changes that remove legacy API, state, and
build incompatibilities. Do not keep temporary compatibility APIs merely to
make intermediate PRs smaller. Each change must have a clear target state,
consumer impact, and verification. Defer only unrelated or speculative work,
not a known customer build failure such as [#117](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/issues/117).

| # | PR | Tickets | Status |
|---|---|---|---|
| 1 | Requirements and native agent deps ([#147](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/pull/147)) | [INTER-2401](https://fingerprintjs.atlassian.net/browse/INTER-2401) | Open, CI green |
| 2 | Built-in Kotlin and AGP 9 compatibility | [INTER-2398](https://fingerprintjs.atlassian.net/browse/INTER-2398), [#117](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/issues/117) | To do |
| 3 | Platform interface | [INTER-2318](https://fingerprintjs.atlassian.net/browse/INTER-2318) | To do |
| 4 | Pigeon channel and complete public API | [INTER-2318](https://fingerprintjs.atlassian.net/browse/INTER-2318), [INTER-2320](https://fingerprintjs.atlassian.net/browse/INTER-2320), [INTER-2396](https://fingerprintjs.atlassian.net/browse/INTER-2396), [INTER-2386](https://fingerprintjs.atlassian.net/browse/INTER-2386), [INTER-2387](https://fingerprintjs.atlassian.net/browse/INTER-2387) | To do |
| 5 | Web interop for agent v4 | [INTER-2319](https://fingerprintjs.atlassian.net/browse/INTER-2319) | To do |
| 6 | Rename repo and package | [INTER-2400](https://fingerprintjs.atlassian.net/browse/INTER-2400) | To do |
| 7 | Docs, migration guide, example app | none | To do |
| 8 | Release 5.0.0 | none | To do |

[INTER-2321](https://fingerprintjs.atlassian.net/browse/INTER-2321) (Swift
Package Manager) shipped in 4.13.0.

PRs 7 and 8 have no ticket. The error model belongs in PR 4: it is part of
the public contract and Pigeon error payload, not a later cleanup.

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

## PR 2. Built-in Kotlin and AGP 9 compatibility

[INTER-2398](https://fingerprintjs.atlassian.net/browse/INTER-2398), GitHub
issue [#117](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/issues/117).

This fixes a current consumer compatibility defect. Under AGP 9, an app can
fail because this plugin applies the legacy Kotlin Gradle Plugin. Flutter's
[plugin-author migration guide](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-plugin-authors)
requires affected plugins to remove that plugin and migrate compiler options.
Flutter describes legacy Kotlin Gradle Plugin support as temporary and plans to
remove it.

Migrate the plugin and example to built-in Kotlin, remove the legacy Kotlin
Gradle Plugin, and use the supported compiler-options DSL. Set the example to
AGP 9. This does not raise the public Flutter floor: Flutter's guide sets the
plugin-author floor at Flutter 3.44 and Dart 3.12, which PR 1 already adopts.

CI proves both supported paths: Flutter 3.44 with AGP 9 and
`android.builtInKotlin=false`, plus latest stable Flutter with AGP 9 and
`android.builtInKotlin=true`. Flutter documents that enabling built-in Kotlin
in an example requires Flutter 3.47+, while the 3.44 path remains supported.

## PR 3. Platform interface

[INTER-2318](https://fingerprintjs.atlassian.net/browse/INTER-2318), partial.

Add `plugin_platform_interface`, `FingerprintPlatform`,
`MethodChannelFingerprint`, `FingerprintWeb`. Public API unchanged.

Removes the web round trip, where Dart calls `invokeMethod` and the web
plugin answers it in the same process. Tests switch to replacing
`FingerprintPlatform.instance`.

Before Pigeon, so the generated code sits inside `MethodChannelFingerprint`.

## PR 4. Pigeon channel and complete public API

[INTER-2320](https://fingerprintjs.atlassian.net/browse/INTER-2320),
[INTER-2396](https://fingerprintjs.atlassian.net/browse/INTER-2396),
[INTER-2386](https://fingerprintjs.atlassian.net/browse/INTER-2386),
[INTER-2387](https://fingerprintjs.atlassian.net/browse/INTER-2387).

This is one atomic public-contract PR. It introduces the new Dart API,
generated Pigeon bindings, flat result, and error model together. It does not
add an adapter for the old static API or response types.

- `Fingerprint` receives immutable `apiKey`, `region`, `endpoints`, and
  platform configuration in its constructor and exposes
  `get({tags, linkedId, timeout})`.
- `FingerprintResult` has `String eventId`, `String visitorId`,
  `int? suspectScore`, and `String? sealedResult`. `suspectScore` is nullable
  because the iOS v4 SDK declares it as `Int?`.
- `AndroidOptions`, `IosOptions`, and `WebOptions` contain platform settings;
  shared settings and the single ordered `endpoints` list stay at top level.
  All timeouts use `Duration`.
- `tags` remains `Map<String, Object?>?`, the current public shape and the
  metadata-object shape in the proposal. Reject scalar and list values at the
  Dart boundary rather than silently giving platforms different semantics.
- `final class FingerprintError implements Exception` has
  `FingerprintErrorCode code`, `String rawCode`, `String? message`, and
  `String? eventId`. Map the actual native and web v4 codes to the enum and
  preserve unfamiliar codes as `unknown`. Do not make React Native's mapping
  the source of truth for another platform.

`implements Exception` is deliberate. `Exception` is a marker interface and
the Dart documentation uses `implements Exception` for application-specific
exceptions; either `implements` or `extends` is valid, but the former avoids
inheriting an implementation the type does not need. See
[Dart core](https://dart.dev/libraries/dart-core#exceptions) and the
[Exception API](https://api.dart.dev/dart-core/Exception-class.html).

Generate Dart, Kotlin, and Swift messages from this contract. Delete the
positional tuple, `FingerprintJSProResponse`, the extended response types,
`ConfidenceScore`, `IpLocation`, `StSeenAt`, and `extendedResponseFormat` in
the same PR. This is the only point at which those public types disappear.

Stateless per call: every get message includes the full config, native keeps
no client between calls. Two Dart clients with different configs stay
independent.

Also fix: `ipAddress` and `osName` accept two key spellings
(`json['ip'] ?? json['ipAddress']`); `sealedResult` is typed `String?` but
both platforms send an empty string.

CI runs Pigeon and fails if it changes tracked generated files. Tests cover
two differently configured `Fingerprint` instances, the full result and error
mapping on Android and iOS, unknown error codes, and a minified Android build.

[INTER-2386](https://fingerprintjs.atlassian.net/browse/INTER-2386) and
[INTER-2387](https://fingerprintjs.atlassian.net/browse/INTER-2387) duplicate
[INTER-2320](https://fingerprintjs.atlassian.net/browse/INTER-2320) and
[INTER-2396](https://fingerprintjs.atlassian.net/browse/INTER-2396). They sit
outside the epic, are assigned to Ilya, and cover React Native too. No link
connects the pairs. Close or link before starting.

## PR 5. Web interop for agent v4

[INTER-2319](https://fingerprintjs.atlassian.net/browse/INTER-2319).

Rewrite `js_agent_interop.dart` for the v4 start function. Remove
`extendedResult` and `scriptUrlPattern`.

Add `urlHashing`, `storageKeyPrefix`, `cacheHit`, and cache with the
`optimize-cost` and `aggressive` presets as a sealed `CacheDuration`, not a
bare `Duration`.

Add the Dart equivalent of React Native's `agentCompatibility` test, which
fails the build when web option keys drift from the agent's.

Add a browser test with a mocked v4 agent. It verifies the start and get flow,
option values, result conversion, and error conversion. A web build alone
cannot prove those runtime behaviors.

## PR 6. Rename repo and package

[INTER-2400](https://fingerprintjs.atlassian.net/browse/INTER-2400).

Repo to `flutter`, package to `fingerprint_flutter`, `FpjsProPlugin` to
`Fingerprint`. The upstream repo is not renamed yet, so this covers both.

Mechanical: package name, library file, podspec, `Package.swift`, Kotlin
package path, example app, changesets config, `scripts/update_version.sh`,
CI workflow.

Update the name-specific release configuration: root `package.json`,
`.changeset/config.json`'s `packageName`, the version-update script, and the
README replacement. Keep the existing tag-driven pub publishing workflow,
then add `flutter pub publish --dry-run` for the renamed package before any
release tag. Confirm `fingerprint_flutter` is available and that the verified
publisher can publish it before merging this PR.

Do this before any prerelease. A new pub name is a new package, so an alpha
must be installable as `fingerprint_flutter`, not the retired name.

## PR 7. Docs, migration guide, example app

No ticket. The web asset path is a numbered migration step, not a footnote.
Document every renamed import, the static-to-instance conversion, removed
extended response fields, error-model change, and updated platform floors.

After the stable `fingerprint_flutter` release is live and verified, mark
`fpjs_pro_plugin` discontinued in its pub.dev Admin tab and set
`fingerprint_flutter` as the suggested replacement. This is pub.dev's
supported migration mechanism: the old package remains available, receives a
DISCONTINUED badge, leaves search results, and can name its replacement. See
[Publishing packages](https://dart.dev/tools/pub/publishing#discontinue-a-package).

## PR 8. Release 5.0.0

No ticket. Merge `v5` into `main`. The major changeset exists from PR 1. The
package is at 4.13.1.

The repository already releases Changesets from `main` and `test`, and its
tag-triggered workflow publishes to pub.dev. Reconfigure the name-specific
files in PR 5, then exercise that existing path rather than inventing another
release process. If external testing is needed, enter Changesets prerelease
mode on `test`, publish `5.0.0-alpha.0`, and have testers depend on that exact
prerelease constraint. Pub.dev documents prereleases as the intended way to
test an in-progress major version. Do not publish an alpha before PR 5 and PR
6: it would not provide a complete cross-platform API under the new package
name. See [Changesets prerelease mode](https://github.com/changesets/changesets/blob/main/docs/command-line-options.md#pre)
and [pub.dev prereleases](https://dart.dev/tools/pub/publishing#publish-prerelease-versions).

## What each PR proves

CI builds the example app on Android, iOS and web every time. Beyond that:

- PR 2: an AGP 9 consumer app builds with the supported Flutter 3.44 path and
  with latest Flutter plus built-in Kotlin enabled.
- PR 3: tests pass after replacing `FingerprintPlatform.instance`.
- PR 4: no positional tuple remains; Pigeon generation is reproducible; the
  public API, result, errors, two-client independence, and minified Android
  error codes are covered.
- PR 5: web option keys match the agent at compile time and the mocked-agent
  browser test verifies the runtime contract.
- PR 6: `flutter pub publish --dry-run` validates the renamed package.
- PR 7: the migration guide is tested by updating the example to use only the
  new package name and public API.
