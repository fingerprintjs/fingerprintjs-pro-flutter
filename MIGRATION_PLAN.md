# Flutter SDK 5.0.0 migration plan

Epic [INTER-2212](https://fingerprintjs.atlassian.net/browse/INTER-2212).
Tickets do not map one to one onto PRs.

Every v5 PR targets `v5`. PR 7 merges `v5` into `main`. Nothing ships from
`main` in between: the native v4 upgrade renames `requestId` to `eventId`,
which breaks the shared Dart response type.

Decided: adopt Pigeon, keep the web implementation in the same package.

## v5 directive

Use this major release for established API, state, and build-compatibility
improvements. No temporary compatibility APIs to make intermediate PRs
smaller. Each PR needs a clear target state, consumer impact, and proof. Defer
only unrelated or speculative work, not known breakage such as
[#117](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/issues/117).

| # | PR | Tickets | Status |
|---|---|---|---|
| 1 | Requirements and native agent deps ([#147](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/pull/147)) | [INTER-2401](https://fingerprintjs.atlassian.net/browse/INTER-2401) | Merged |
| 2 | Built-in Kotlin and AGP 9 compatibility ([#149](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/pull/149)) | [INTER-2398](https://fingerprintjs.atlassian.net/browse/INTER-2398), [#117](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/issues/117) | Merged |
| 3 | Platform interface ([#153](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/pull/153)) | [INTER-2318](https://fingerprintjs.atlassian.net/browse/INTER-2318) | In review |
| 4a | Dart foundations: result, error matrix, tags ([#156](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/pull/156)) | [INTER-2320](https://fingerprintjs.atlassian.net/browse/INTER-2320), [INTER-2319](https://fingerprintjs.atlassian.net/browse/INTER-2319) | In review |
| 4b | Pigeon contract and native implementations | [INTER-2318](https://fingerprintjs.atlassian.net/browse/INTER-2318), [INTER-2386](https://fingerprintjs.atlassian.net/browse/INTER-2386), [INTER-2387](https://fingerprintjs.atlassian.net/browse/INTER-2387) | To do |
| 4c | Public API swap and web v4 | [INTER-2320](https://fingerprintjs.atlassian.net/browse/INTER-2320), [INTER-2396](https://fingerprintjs.atlassian.net/browse/INTER-2396) | To do |
| 5 | Rename repo and package | [INTER-2400](https://fingerprintjs.atlassian.net/browse/INTER-2400) | To do |
| 6 | Docs and migration guide | none | To do |
| 7 | Release 5.0.0 | none | To do |

Ticket notes:

- [INTER-2321](https://fingerprintjs.atlassian.net/browse/INTER-2321) (Swift
  Package Manager) shipped in 4.13.0.
- [INTER-2386](https://fingerprintjs.atlassian.net/browse/INTER-2386) and
  [INTER-2387](https://fingerprintjs.atlassian.net/browse/INTER-2387)
  duplicate [INTER-2320](https://fingerprintjs.atlassian.net/browse/INTER-2320)
  and [INTER-2396](https://fingerprintjs.atlassian.net/browse/INTER-2396),
  sit outside the epic, are assigned to Ilya, and cover React Native too.
  Close or link before starting.
- PRs 6 and 7 have no ticket.

## PR 1. Requirements and native agent deps

Merged in [#147](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/pull/147).

Flutter 3.44, Dart 3.12, Android API 24, iOS/tvOS 15, Xcode 16, Swift 6.
Android v4 `4.0.0`, iOS `Fingerprint-iOS`/`fingerprint-ios`, Pigeon 28.1.0.
Android build baseline AGP 8.13.2, Gradle 8.13, Kotlin 2.3.20, compileSdk 36,
bytecode Java 11; PR 2 upgrades the toolchain.

Kotlin 2.3.20 compiles without `-Xskip-metadata-version-check`, which React
Native needed for the same Android SDK. This was the largest open risk.

Two defects it leaves for PR 4:

- **Android error codes are R8-unsafe.** They come from
  `error.javaClass.simpleName`, so a consumer's R8 can rename the classes and
  the codes come out wrong in minified release builds. 4b replaces the
  reflection with an exhaustive `when (error) { is ApiKeyRequired -> ... }`,
  and derives `rawCode` from the same mapping. Not a keep rule: it would leak
  into every consumer build.

  The v4 SDK looks like it ships no consumer rules at all. Its
  `build.gradle.kts` declares no `consumerProguardFiles`, and its three `.pro`
  files are DexGuard config for obfuscating the SDK itself. The `-keep` on
  `@ProguardKeep` covers all 30 error classes, but only for the SDK's own
  DexGuard pass, and the annotation is `internal` and stripped from the
  published sources. Unverified against the published AAR: the Maven host
  `maven.fpregistry.io` is not reachable from a sandboxed agent. Check the real
  artifact during 4b. Either way the fix is the same.
- **The positional tuple lies.** Index 0 is named `requestId` and carries
  `eventId`; index 1 is named `confidenceScore` and carries `suspectScore`.
  4b removes it.

## PR 2. Built-in Kotlin and AGP 9 compatibility

[INTER-2398](https://fingerprintjs.atlassian.net/browse/INTER-2398),
[#117](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/issues/117).

Fixes a live consumer defect: under AGP 9 an app can fail because this plugin
applies the legacy Kotlin Gradle Plugin. Flutter's
[plugin-author guide](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-plugin-authors)
requires affected plugins to remove it and migrate compiler options.

Migrate the plugin and example to built-in Kotlin and the supported
compiler-options DSL. [AGP 9.0.1](https://developer.android.com/build/releases/agp-9-0-0-release-notes),
Gradle 9.1, JDK 17 as the build toolchain; keep generated bytecode at Java 11
unless an Android v4 build proves otherwise. Validate the v4 artifact against
AGP 9's built-in Kotlin rather than assuming its metadata is readable.

**Proves:** an AGP 9 consumer app builds on the Flutter 3.44 path with
`android.builtInKotlin=false`, and on latest stable Flutter with
`android.builtInKotlin=true`. Enabling built-in Kotlin in an example needs
Flutter 3.47+; the 3.44 path stays supported.

## PR 3. Platform interface

[INTER-2318](https://fingerprintjs.atlassian.net/browse/INTER-2318), partial.

Add `plugin_platform_interface`, `FingerprintPlatform`,
`MethodChannelFingerprint`, `FingerprintWeb`. Public API unchanged. Removes
the web round trip, where Dart calls `invokeMethod` and the web plugin answers
it in the same process. Comes before Pigeon so the generated code sits inside
`MethodChannelFingerprint`.

**Proves:** tests pass after replacing `FingerprintPlatform.instance`.

## PR 4. Complete v4 API: Pigeon and web

One contract, three PRs. Nothing publishes before the prerelease after PR 5,
so the constraints are that `v5` is coherent by PR 5 and that each PR is
provable on its own. Splitting by artifact fails the second: a Pigeon contract
wired to stubs asserts only that codegen ran. Split by provable unit.

| | Scope | Proves |
|---|---|---|
| **4a** | `FingerprintResult`, `FingerprintError`, `FingerprintErrorCode` and the error matrix, tag normalization and validation. Pure Dart, public API unchanged. Landed in `lib/src`, unexported; 4c exports it. | Error matrix, result mapping, tag handling and unknown codes pass unit tests with no native or web code. |
| **4b** | Pigeon bindings, Kotlin and Swift implementations, config-keyed client memoization. Public API still unchanged. | Generated code is reproducible, Android and iOS deliver results and errors through the new contract, one client serves repeated calls, error codes survive a minified build. |
| **4c** | New `Fingerprint` API, v4 web rewrite, deletions, example app. | No tuple or v3 web implementation remains; two-client independence, scalar and list tag wrapping, mocked web agent, and the example app on all three platforms. |

The public API never ships over a v3 web implementation. That binds at 4c.

### Public contract

- `Fingerprint` takes immutable `apiKey`, `region`, `endpoints`, and platform
  configuration in its constructor, and exposes `get({tags, linkedId,
  timeout})`.
- `FingerprintResult`: `String eventId`, `String visitorId`,
  `int? suspectScore`, `String? sealedResult`, web-only `bool? cacheHit`.
  `suspectScore` is nullable because the iOS v4 SDK declares it `Int?`; React
  Native's `-1` sentinel is not carried over. A missing Zero Trust `visitorId`
  normalizes to `''`.
- `AndroidOptions`, `IosOptions`, `WebOptions` hold platform settings; shared
  settings and the single ordered `endpoints` list stay at top level. All
  timeouts are `Duration`.
- `final class FingerprintError implements Exception` with
  `FingerprintErrorCode code`, `String rawCode`, `String? message`,
  `String? eventId`. Android sends the literal `"Unknown"` as the event id when
  a failure never reached the server; that and an empty string normalize to
  `null`, as does an empty message. `rawCode` is the exception and is never
  rewritten, empty included: a platform that reported no code is worth telling
  apart from one that reported `unknown_error`, and `code` is `unknown` for
  both. `implements` rather than `extends` avoids inheriting an implementation
  the type does not need ([Dart core](https://dart.dev/libraries/dart-core#exceptions)).
- `tags` accepts any recursively JSON-compatible string, number, boolean,
  list, or map. Anything that is not a root map, scalars and root lists alike,
  is wrapped as `{'tag': value}` before Pigeon, because Android and iOS
  require a map; web forwards it unwrapped. This matches React Native. Reject
  what cannot reach the server: non-JSON Dart objects, non-string keys,
  non-finite numbers, and a collection that contains itself. React Native
  rejects none of these and silently drops what it cannot convert.
- No client-side tag size cap. The
  [16 KB limit](https://docs.fingerprint.com/docs/tagging-information) is a
  server-side product limit reported as `payload_too_large`. Document it
  instead.
- `sealedResult` is `String?` but both native platforms send an empty string,
  normalized to `null`.
- Nothing to fix for the `ipAddress` and `osName` two key spellings. Those
  fields only exist on the extended response types, which 4c deletes.

Deleted in 4c with the swap: the positional tuple, `FingerprintJSProResponse`,
the extended response types, `ConfidenceScore`, `IpLocation`, `StSeenAt`,
`extendedResponseFormat`.

### Error matrix

Done in 4a. `lib/src/fingerprint_error.dart` is the matrix and is
authoritative; do not re-derive it from the v3 list.

Codes are the API's snake_case error keys, which is what the web agent
reports, what the Android SDK keys its error classes off, and what
[React Native settled on](https://github.com/fingerprintjs/fingerprintjs-pro-react-native/commit/1fcc272c943e362a12fe1c0f21429a5f47c22e81).
One code covers all three platforms. Unmapped codes become `unknown` and
`rawCode` keeps the platform's string.

Members are grouped into server and client errors. That grouping is the
contract: it tells 4b whether to forward an event id. Two entries break their
group, and both carry a comment saying why:

- `response_cannot_be_parsed` can carry an id. The reply arrived, only reading
  it failed.
- `sandboxed_iframe` cannot, despite sitting in the agent's `ApiErrorCode`
  type union. The agent raises it locally.

4b must key the Kotlin off the server condition, not the class name. Two
Android classes are named for something else, and React Native gets both
wrong, giving one condition two codes depending on platform:

- `RequestTimeout` comes from the key `request_read_timeout`.
- `RequestNotFound` comes from `event_not_found`.

The enum is closed, so it lists every code a platform can emit, including six
that React Native's own `ErrorCode` union omits while its bridges can still
emit them: `secret_api_key_required`, `secret_api_key_not_found`,
`subscription_not_found`, `request_not_found`, `state_not_ready`,
`ruleset_not_found`. Its union is an open string type and can afford the gap;
a closed enum cannot, or `unknown` would mean both "new" and "we skipped it".

These v3 codes are gone in v4 and are not in the matrix: `ApiKeyExpired`,
`OriginNotAvailable`, `PackageNotAuthorized`, `HeaderRestricted`,
`NotAvailableForCrawlBots`, `NotAvailableWithoutUA`, `UnsupportedVersion`,
`IntegrationFailure`.

### Native client lifecycle

Two separate decisions; only the first is an invariant.

**Messages are stateless.** Every get carries the full config and nothing
refers to a previously established native client, so two Dart clients with
different configs stay independent and no `init`/`get` ordering can fail.

**Clients are not.** Each platform holds a `Map<configKey, NativeClient>`
keyed by a hash of the resolved config, created on first use. This keeps
independence without a client handle or disposal protocol, which Dart
finalizers cannot reliably close.

Reuse is a correctness requirement, not only latency: the iOS SDK documents
that with `allowUseOfLocationData` the client should be created early and kept
for the app's lifetime for location precision, so a per-call client would pay
`locationTimeoutMillis` every call. Android documents nothing either way and
its artifact is obfuscated. 4b asserts reuse rather than assuming it, and the
Android warm-state question goes to the native SDK team.

### Native fixes for 4b

Current defects, found in the v4 sources. Not new work:

- **iOS messages are the generic bridged text.** `FPJSError+Flutter.swift`
  reads `localizedDescription`, but v4's `FPError` implements
  `CustomStringConvertible` and not `LocalizedError`, so the seven
  non-`apiError` cases surface `The operation couldn't be completed.
  (Fingerprint.FPError error N.)`. Read `description` instead.
- **Both platforms drop the event id.** iOS never reads `APIError.eventId`,
  non-optional in v4, and Android never reads `Error.eventId`.
  `FingerprintError.eventId` stays null until 4b forwards them. Only
  `FPError.apiError` carries one on iOS.
- **Decide what an unrecognized iOS server code maps to.** `APIError.Code` is
  decoded from the server, so `errorDetails` or its `code` can be nil. React
  Native returns `failed`. Prefer `unknown_error`: `failed` is itself a
  specific server code. Note also that `APIError.Code` has no explicit raw
  values, so `rawValue` is the camelCase case name and a future code leaks as
  e.g. `tooManyRequests`. The matrix maps only snake_case, so such a code
  lands on `unknown`, which is correct.

### Web (4c)

The v4 agent is a different npm package. `@fingerprintjs/fingerprintjs-pro`
has no v4 at all, its latest is 3.12.15, and `web/index.js` pins 3.12.12. v4
is [`@fingerprint/agent`](https://www.npmjs.com/package/@fingerprint/agent),
which is where the start/get API, the cache options and the snake_case error
codes come from. So this is a package swap, not a version bump, and the
matrix's web column already assumes it.

Rewrite `FingerprintWeb` for the v4 start/get API. Add `urlHashing`,
`storageKeyPrefix`, and an optional `cache` configuration: required storage
(`sessionStorage`, `localStorage`, `agent`), a duration (`optimize-cost`,
`aggressive`, or a custom `Duration` up to 12 hours), and an optional key
prefix. Map the agent's `cache_hit` to `cacheHit`; it is not a start option.
Remove `extendedResult` and `scriptUrlPattern`. No `remoteControlDetection`:
it is absent from the
[React Native v4 web contract](https://github.com/fingerprintjs/fingerprintjs-pro-react-native/blob/1fcc272c943e362a12fe1c0f21429a5f47c22e81/sdk/src/types.ts).

The mocked-agent browser test covers start, get, cache configuration, result
conversion including cache hit and a missing Zero Trust visitor ID, and errors.

### Example app

Moves to the new API in 4c, with the deletions. Not documentation work for PR
6: CI builds the example on every PR, and `example/lib/main.dart` uses
`extendedResponseFormat` and the static
`FpjsProPlugin.getVisitorId`/`getVisitorData`. It is also the only end-to-end
proof that the rewritten API works on a real device against a real endpoint,
so it is an acceptance criterion for the rewrite. PR 5 renames its import,
PR 6 documents it.

CI also runs Pigeon and fails if it changes tracked generated files.

### Run the browser tests, even for pure Dart

`flutter test` and `flutter test --platform chrome` disagree on pure Dart.
Code with no native or web dependency can still pass on one and fail on the
other, so run both.

Known case: on the web every number is a double and `double.infinity is int`
is true, because the check compiles to a floor comparison. An `int` branch
ahead of a `double` branch then swallows infinity. Prefer one `num` branch.
Same family as
[#137](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/issues/137),
which is why `invalid_runtime_check_with_js_interop_types` is an error in
`analysis_options.yaml`. The analyzer does not catch this one.

## PR 5. Rename repo and package

[INTER-2400](https://fingerprintjs.atlassian.net/browse/INTER-2400).

Repo to `flutter`, package to `fingerprint_flutter`, `FpjsProPlugin` to
`Fingerprint`. The upstream repo is not renamed yet, so this covers both.

Rename the package, library, podspec, `Package.swift`, Kotlin path, example,
and release configuration. Update root `package.json`,
`.changeset/config.json`'s `packageName`, and `scripts/update_version.sh`.
Replace the existing major Changeset, whose frontmatter names the old npm
package, with `fingerprint_flutter: major`, otherwise the rename orphans the
v5 bump.

Keep the tag-driven pub publishing workflow. Before a release tag, verify name
availability and publisher access, run `pnpm changeset status`, version to
`5.0.0-alpha.0` on `test`, and run `flutter pub publish --dry-run`.

This comes before any prerelease: a new pub name is a new package, so an alpha
must be installable as `fingerprint_flutter`.

**Proves:** Changesets produces `fingerprint_flutter 5.0.0-alpha.0`, pub dry
run succeeds, and the example resolves the renamed package.

## PR 6. Docs and migration guide

No ticket. The example already runs the new API under the new name, so this PR
documents that path rather than performing it. Cover every renamed import, the
static-to-instance conversion, removed extended response fields, the error
model change, updated platform floors, and the web asset path as a numbered
step.

After the stable release is live and verified, mark `fpjs_pro_plugin`
discontinued in its pub.dev Admin tab with `fingerprint_flutter` as the
suggested replacement
([Publishing packages](https://dart.dev/tools/pub/publishing#discontinue-a-package)).

**Proves:** the guide is walked end to end against the migrated example and
every step matches what the example does.

**Open question:** whether `fpjs_pro_plugin` gets a final 4.13.x
migration-notice release and/or further maintenance or security fixes. Does
not change the discontinuation step.

## PR 7. Release 5.0.0

No ticket. Merge `v5` into `main`. The major changeset exists from PR 1; the
package is at 4.13.1.

The repository already releases Changesets from `main` and `test`, then
publishes the version tag to pub.dev. Use that path: a prerelease from `test`
after PR 5, stable 5.0.0 from `main` after PR 6. See
[Changesets prerelease mode](https://github.com/changesets/changesets/blob/main/docs/command-line-options.md#pre)
and [pub.dev prereleases](https://dart.dev/tools/pub/publishing#publish-prerelease-versions).
