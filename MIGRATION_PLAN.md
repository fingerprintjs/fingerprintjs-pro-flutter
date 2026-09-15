# Flutter SDK 5.0.0 migration plan

Epic [INTER-2212](https://fingerprintjs.atlassian.net/browse/INTER-2212).
Tickets do not map one to one onto PRs.

Every v5 PR targets `v5`. PR 7 merges `v5` into `main`. Nothing ships from
`main` in between: the native v4 upgrade renames `requestId` to `eventId`,
which breaks the shared Dart response type.

Decided: adopt Pigeon, keep the web implementation in the same package.

## v5 directive

Use this major release for established API, state, and build-compatibility
improvements. Do not retain temporary compatibility APIs to make intermediate
PRs smaller. Each PR needs a clear target state, consumer impact, and proof.
Defer only unrelated or speculative work, not known breakage such as
[#117](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/issues/117).

| # | PR | Tickets | Status |
|---|---|---|---|
| 1 | Requirements and native agent deps ([#147](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/pull/147)) | [INTER-2401](https://fingerprintjs.atlassian.net/browse/INTER-2401) | Merged |
| 2 | Built-in Kotlin and AGP 9 compatibility | [INTER-2398](https://fingerprintjs.atlassian.net/browse/INTER-2398), [#117](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/issues/117) | To do |
| 3 | Platform interface | [INTER-2318](https://fingerprintjs.atlassian.net/browse/INTER-2318) | To do |
| 4a | Dart foundations: result, error matrix, tags | [INTER-2320](https://fingerprintjs.atlassian.net/browse/INTER-2320), [INTER-2319](https://fingerprintjs.atlassian.net/browse/INTER-2319) | To do |
| 4b | Pigeon contract and native implementations | [INTER-2318](https://fingerprintjs.atlassian.net/browse/INTER-2318), [INTER-2386](https://fingerprintjs.atlassian.net/browse/INTER-2386), [INTER-2387](https://fingerprintjs.atlassian.net/browse/INTER-2387) | To do |
| 4c | Public API swap and web v4 | [INTER-2320](https://fingerprintjs.atlassian.net/browse/INTER-2320), [INTER-2396](https://fingerprintjs.atlassian.net/browse/INTER-2396) | To do |
| 5 | Rename repo and package | [INTER-2400](https://fingerprintjs.atlassian.net/browse/INTER-2400) | To do |
| 6 | Docs and migration guide | none | To do |
| 7 | Release 5.0.0 | none | To do |

[INTER-2321](https://fingerprintjs.atlassian.net/browse/INTER-2321) (Swift
Package Manager) shipped in 4.13.0.

PRs 6 and 7 have no ticket. The error model belongs in PR 4a: it is part of
the public contract and Pigeon error payload, not a later cleanup.

## PR 1. Requirements and native agent deps

[#147](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/pull/147),
merged. [INTER-2401](https://fingerprintjs.atlassian.net/browse/INTER-2401).

Set Flutter 3.44, Dart 3.12, Android API 24, iOS/tvOS 15, Xcode 16, and Swift
6. Use Android v4 `4.0.0`, iOS `Fingerprint-iOS`/`fingerprint-ios`, and
Pigeon 28.1.0. The initial Android build baseline is AGP 8.13.2, Gradle 8.13,
Kotlin 2.3.20, Java 11, and compileSdk 36; PR 2 upgrades its build toolchain.

Kotlin 2.3.20 compiles without `-Xskip-metadata-version-check`. React Native
needed that flag for the same Android SDK. This was the largest open risk.

Two follow-ups:

- Android error codes come from `error.javaClass.simpleName`. R8 renames
  classes, so codes are correct in debug and wrong in minified release
  builds. Confirmed against the shipped artifact: `sdk-4.0.0.aar`'s consumer
  `proguard.txt` names only 11 of the ~37 `com.fingerprint.android.*` error
  classes, and its `-keeppackagenames` rule preserves packages, not class
  names. `ApiKeyRequired`, `Failed`, `WrongRegion`, `RequestTimeout`, and
  `NetworkError` are among the unkept ones. PR 4b replaces the reflection with
  an exhaustive `when (error) { is ApiKeyRequired -> ... }` mapping, as the
  [React Native SDK does](https://github.com/fingerprintjs/fingerprintjs-pro-react-native/blob/acac23e/sdk/android/src/main/java/com/fingerprintjs/reactnative/RNFingerprintjsProModule.kt).
  Type checks are obfuscation-safe by construction; a keep rule shipped from
  this plugin would leak into every consumer build, so it is not the remedy.
  `rawCode` must come from the same mapping, not from `simpleName`. Prove it
  with an assertion on an actual error code in a minified release build.
- Tuple index 0 is named `requestId` and carries `eventId`. Index 1 is named
  `confidenceScore` and carries `suspectScore`. PR 4b removes the tuple.

## PR 2. Built-in Kotlin and AGP 9 compatibility

[INTER-2398](https://fingerprintjs.atlassian.net/browse/INTER-2398), GitHub
issue [#117](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/issues/117).

This fixes a current consumer compatibility defect: under AGP 9, an app can
fail because this plugin applies the legacy Kotlin Gradle Plugin. Flutter's
[plugin-author migration guide](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-plugin-authors)
requires affected plugins to remove it and migrate compiler options.

Migrate the plugin and example to built-in Kotlin and use the supported
compiler-options DSL. Use [AGP 9.0.1](https://developer.android.com/build/releases/agp-9-0-0-release-notes),
Gradle 9.1, and JDK 17; keep generated bytecode at Java 11 unless an Android
v4 build proves otherwise. Validate the v4 artifact against AGP 9's built-in
Kotlin: do not assume its Kotlin 2.3.20 metadata is readable.

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

## PR 4. Complete v4 API: Pigeon and web (4a, 4b, 4c)

[INTER-2320](https://fingerprintjs.atlassian.net/browse/INTER-2320),
[INTER-2396](https://fingerprintjs.atlassian.net/browse/INTER-2396),
[INTER-2386](https://fingerprintjs.atlassian.net/browse/INTER-2386),
[INTER-2387](https://fingerprintjs.atlassian.net/browse/INTER-2387),
[INTER-2319](https://fingerprintjs.atlassian.net/browse/INTER-2319).

This section defines one contract, delivered in three PRs. It introduces the
new Dart API, generated Pigeon bindings, flat result, and error model. It does
not add an adapter for the old static API or response types.

### Why three PRs, and what atomicity actually requires

Delivered as a single PR this is the Pigeon contract, the Kotlin and Swift
implementations, the full Dart public API, an error matrix of roughly 37 codes
across three platforms, tag handling, the v4 web rewrite, seven type
deletions, and the example app migration. That is not reviewable in one pass
and not bisectable when something breaks.

The constraint to respect is narrower than "one atomic PR". Every v5 PR
targets `v5` and nothing publishes until the prerelease from `test` after PR
5, so no consumer observes any intermediate state here. What must hold is that
`v5` is coherent by PR 5, and that each PR is independently provable. Splitting
by artifact fails the second test: a Pigeon contract wired to stubs has no
behavior to assert beyond "codegen ran", and its shape cannot be reviewed
until something uses it, so it gets reviewed twice. Split by provable unit
instead.

- **4a. Dart foundations.** `FingerprintResult`, `FingerprintError`,
  `FingerprintErrorCode` and the full error matrix, tag normalization and
  validation. Pure Dart, no native, no Pigeon, public API unchanged. Proven by
  unit tests alone. This is the heaviest review item in the set and it has no
  native dependency, so it does not belong in the same PR as codegen.
- **4b. Pigeon contract and native.** Generated bindings, Kotlin and Swift
  implementations, config-keyed client memoization, minified Android build
  assertion. Exercised through the platform interface by integration tests;
  public API still unchanged. Real behavior, real proof.
- **4c. Public swap.** The new `Fingerprint` API, the v4 web rewrite, the
  deletions listed below, and the example app. The rule that the new public
  API never ships over a v3 web implementation binds here, and only here.

The rest of this section describes the target state of all three.

- `Fingerprint` receives immutable `apiKey`, `region`, `endpoints`, and
  platform configuration in its constructor and exposes
  `get({tags, linkedId, timeout})`.
- `FingerprintResult` has `String eventId`, `String visitorId`,
  `int? suspectScore`, `String? sealedResult`, and web-only `bool? cacheHit`.
  `suspectScore` is nullable because the iOS v4 SDK declares it as `Int?`.
  This is a deliberate divergence from React Native, which reports a `-1`
  sentinel; Dart has no reason to encode absence as a magic number.
  Normalize a missing Zero Trust `visitorId` to `''`, preserving the non-null
  result shape used by React Native.
- `AndroidOptions`, `IosOptions`, and `WebOptions` contain platform settings;
  shared settings and the single ordered `endpoints` list stay at top level.
  All timeouts use `Duration`.
- `tags` accepts a string, number, boolean, list, or map, recursively
  JSON-compatible. Match React Native's adapter exactly: anything that is not
  a root map — scalars and root lists alike — is wrapped as `{'tag': value}`
  before Pigeon, because Android and iOS receive a map. Web forwards the
  value to the agent unwrapped. Reject only what cannot cross the boundary at
  all: non-JSON Dart objects and non-string map keys.

  Do not enforce a client-side size cap. The documented 16 KB tag limit is a
  server-side product limit, not an SDK invariant; React Native does not
  check it, and the API already reports oversized payloads as
  `payload_too_large`, which the error model maps. Duplicating the limit in
  Dart would reject payloads the server accepts whenever the limit changes.
  Document it in the API reference instead. See
  [Tagging information](https://docs.fingerprint.com/docs/tagging-information).
- `final class FingerprintError implements Exception` has
  `FingerprintErrorCode code`, `String rawCode`, `String? message`, and
  `String? eventId`. Android's `Error.eventId` carries the literal `"Unknown"`
  sentinel when the failure never reached the server; normalize that, and an
  empty string, to `null` so `eventId` means what it says.

`implements Exception` is deliberate. `Exception` is a marker interface and
the Dart documentation uses `implements Exception` for application-specific
exceptions; either `implements` or `extends` is valid, but the former avoids
inheriting an implementation the type does not need. See
[Dart core](https://dart.dev/libraries/dart-core#exceptions) and the
[Exception API](https://api.dart.dev/dart-core/Exception-class.html).

Generate Dart, Kotlin, and Swift messages from this contract (4b). Delete the
positional tuple, `FingerprintJSProResponse`, the extended response types,
`ConfidenceScore`, `IpLocation`, `StSeenAt`, and `extendedResponseFormat` in
4c, alongside the public API swap. That is the only point at which those
public types disappear.

### Stateless messages, memoized native clients

These are two separate decisions and the plan keeps only the first as an
invariant.

Every get message includes the full config. Nothing in the Pigeon contract
refers to a previously established native client, so two Dart clients with
different configs stay independent and no `init`/`get` ordering can fail.

Native does not construct a client per call. Each platform holds a
`Map<configKey, NativeClient>` keyed by a stable hash of the resolved config
and creates a client on first use. Same config, same warm client; different
config, different client. This preserves the independence invariant without a
client-handle or disposal protocol: Dart finalizers are not guaranteed to
run, so handing out native client IDs would create a lifetime we cannot
reliably close.

The reuse matters for correctness, not only latency. The iOS SDK documents
that with `allowUseOfLocationData` enabled you should initialize the client as
early as possible and keep the same instance for the app's lifetime, for
location precision. A per-call client would restart location acquisition on
every call and pay `locationTimeoutMillis` each time. The Android SDK's docs
make no equivalent statement either way, and its artifact is obfuscated, so
its warm-up cost is not determinable from the outside.

PR 4b therefore proves reuse rather than assuming it: assert the same native
client instance serves repeated calls with an unchanged config, and that a
second call does not repeat first-call initialization. Confirm the Android
client's warm-state behavior with the native SDK team before relying on any
stronger claim.

Also fix: `ipAddress` and `osName` accept two key spellings
(`json['ip'] ?? json['ipAddress']`); `sealedResult` is typed `String?` but
both native platforms send an empty string, which Dart normalizes to `null`.

The example app moves to the new API in 4c, with the deletions. This is not
documentation work that can wait for PR 6: CI builds the example on Android,
iOS and web on every PR, and `example/lib/main.dart` uses
`extendedResponseFormat` and the static
`FpjsProPlugin.getVisitorId`/`getVisitorData` calls that 4c deletes. Leaving
it behind breaks CI for three PRs. The example is also the
only end-to-end proof that the rewritten API is usable on a real device
against a real endpoint, so it is an acceptance criterion for the rewrite, not
a follow-up. PR 5 updates its package name and import; PR 6 documents it.

CI runs Pigeon and fails if it changes tracked generated files. Tests cover,
in the PR that introduces each: error and result mapping, tag normalization
and rejection of non-JSON values, and unknown error codes (4a); native client
reuse across repeated calls with one config, Android and iOS result and error
delivery, and a minified Android build (4b); two differently configured
`Fingerprint` instances, scalar- and list-tag wrapping on native versus direct
forwarding on web, and the mocked web agent (4c).

Before generating bindings, add and review an error matrix for every known
Android, iOS, and web raw code: `FingerprintErrorCode`, message behavior, and
whether it carries `eventId`. Preserve unmapped codes as `unknown`; native v4
sources are authoritative. Include only errors a client SDK can emit; exclude
Server API-only errors, as the
[React Native SDK does](https://github.com/fingerprintjs/fingerprintjs-pro-react-native/commit/1fcc272c943e362a12fe1c0f21429a5f47c22e81).

Rewrite `FingerprintWeb` for the v4 start/get API in 4c, with the public
swap. Add
`urlHashing`, `storageKeyPrefix`, and an optional `cache` configuration with
required storage (`sessionStorage`, `localStorage`, or `agent`), a duration
(`optimize-cost`, `aggressive`, or custom `Duration` up to 12 hours), and an
optional key prefix. Map the agent's `cache_hit` result to `cacheHit`; it is
not a start option. Do not add `remoteControlDetection`: it is absent from the
current [React Native v4 web contract](https://github.com/fingerprintjs/fingerprintjs-pro-react-native/blob/1fcc272c943e362a12fe1c0f21429a5f47c22e81/sdk/src/types.ts).
Remove `extendedResult` and `scriptUrlPattern`.

The mocked-agent browser test verifies start, get, cache configuration and
result conversion (including cache hit and a missing Zero Trust visitor ID),
and errors. No PR may expose the new public API with a v3 web implementation.

[INTER-2386](https://fingerprintjs.atlassian.net/browse/INTER-2386) and
[INTER-2387](https://fingerprintjs.atlassian.net/browse/INTER-2387) duplicate
[INTER-2320](https://fingerprintjs.atlassian.net/browse/INTER-2320) and
[INTER-2396](https://fingerprintjs.atlassian.net/browse/INTER-2396). They sit
outside the epic, are assigned to Ilya, and cover React Native too. No link
connects the pairs. Close or link before starting.

## PR 5. Rename repo and package

[INTER-2400](https://fingerprintjs.atlassian.net/browse/INTER-2400).

Repo to `flutter`, package to `fingerprint_flutter`, `FpjsProPlugin` to
`Fingerprint`. The upstream repo is not renamed yet, so this covers both.

Rename the package, library, podspec, `Package.swift`, Kotlin path, example,
and release configuration. Update root `package.json`,
`.changeset/config.json`'s `packageName`, and `scripts/update_version.sh`.
Replace the existing major Changeset, whose frontmatter names the old npm
package, with `fingerprint_flutter: major`; otherwise the rename orphans the
v5 bump.

Keep the existing tag-driven pub publishing workflow. Before a release tag,
verify name availability and publisher access, then run `pnpm changeset
status`, version `fingerprint_flutter` to `5.0.0-alpha.0` on `test`, and run
`flutter pub publish --dry-run`.

Do this before any prerelease. A new pub name is a new package, so an alpha
must be installable as `fingerprint_flutter`, not the retired name.

## PR 6. Docs and migration guide

No ticket. The example app already runs on the new API (PR 4c) under the new
package name (PR 5); this PR documents that path rather than performing it.
The web asset path is a numbered migration step, not a footnote.
Document every renamed import, the static-to-instance conversion, removed
extended response fields, error-model change, and updated platform floors.

After the stable `fingerprint_flutter` release is live and verified, mark
`fpjs_pro_plugin` discontinued in its pub.dev Admin tab and set
`fingerprint_flutter` as the suggested replacement. This is pub.dev's
supported migration mechanism: the old package remains available, receives a
DISCONTINUED badge, leaves search results, and can name its replacement. See
[Publishing packages](https://dart.dev/tools/pub/publishing#discontinue-a-package).

Open question — old-package policy: before release, decide whether
`fpjs_pro_plugin` gets a final 4.13.x migration-notice release and/or further
maintenance or security fixes. This does not change the discontinuation step.

## PR 7. Release 5.0.0

No ticket. Merge `v5` into `main`. The major changeset exists from PR 1. The
package is at 4.13.1.

The repository already releases Changesets from `main` and `test`, then
publishes the version tag to pub.dev. Use that path. A prerelease goes from
`test` after PR 5; stable 5.0.0 goes from `main` after PR 6. See
[Changesets prerelease mode](https://github.com/changesets/changesets/blob/main/docs/command-line-options.md#pre)
and [pub.dev prereleases](https://dart.dev/tools/pub/publishing#publish-prerelease-versions).

## What each PR proves

CI builds the example app on Android, iOS and web every time. Beyond that:

- PR 2: an AGP 9 consumer app builds with the supported Flutter 3.44 path and
  with latest Flutter plus built-in Kotlin enabled.
- PR 3: tests pass after replacing `FingerprintPlatform.instance`.
- PR 4a: the error matrix, result mapping, and tag handling pass unit tests
  with no native or web code involved, and the public API is untouched.
- PR 4b: generated code is reproducible, Android and iOS deliver results and
  errors through the new contract, one native client serves repeated calls
  with an unchanged config, and error codes survive a minified build.
- PR 4c: no positional tuple or v3 web implementation remains; two-client
  independence and mocked web-agent behavior are covered, and the example app
  builds and identifies on Android, iOS and web using only the new API.
- PR 5: Changesets produces `fingerprint_flutter 5.0.0-alpha.0` and pub dry
  run succeeds; the example resolves the renamed package.
- PR 6: the migration guide is walked end to end against the migrated example,
  and every step it names matches what the example actually does.
