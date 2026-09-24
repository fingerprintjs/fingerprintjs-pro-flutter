# Contributing to FingerprintJS Pro Flutter integration

## Development Environment

Before starting work on the repository please configure the environment and emulators.
1. Install Flutter using [instruction for your OS](https://docs.flutter.dev/get-started/install).
2. Follow official recommendations [about setting up IDE](https://docs.flutter.dev/get-started/editor?tab=androidstudio).

## Development playground

In the `example` folder you can find the demo application. Read the [instruction](https://docs.flutter.dev/get-started/test-drive?tab=androidstudio) on how to start the example app.

To build the iOS example with Swift Package Manager, clone this repo into a folder named `fpjs_pro_plugin` (the Dart package name). Flutter uses that folder name as the SwiftPM package identity ([flutter#186881](https://github.com/flutter/flutter/issues/186881)). A clone named `fingerprintjs-pro-flutter` will fail. pub.dev installs are unaffected.

This is temporary. Drop this note and the CI `path:` workaround once [flutter#188647](https://github.com/flutter/flutter/pull/188647) reaches stable.

## Architecture

The package is one Dart API over three platforms:

- Android and iOS use the Fingerprint native SDKs
- Web uses the Fingerprint JS agent

App authors should only import public types from `lib/`. Each platform implements the same Dart interface.

### Pigeon

Android and iOS cannot call Dart types directly. [Pigeon](https://pub.dev/packages/pigeon) is the typed contract between Dart and those SDKs. The source of truth is `pigeons/fingerprint_api.dart`. Pigeon generates Dart, Kotlin, and Swift from that file. Do not edit the generated files.

To change what crosses to Android and iOS:

1. Edit `pigeons/fingerprint_api.dart`.
2. Run `dart run pigeon --input pigeons/fingerprint_api.dart`.
3. Implement the new methods on both native sides.
4. Commit the generated files with the hand-written changes.

CI runs Pigeon again and fails if the generated files do not match.

Keep Android and iOS behavior aligned even when the two SDKs look different. Identification results and error codes should mean the same thing on both.

Web does not use Pigeon.

## Testing

For running tests just call `flutter test`.

### Integration smoke test

The Maestro smoke test builds the normal example app, waits for the Dart client
to be created,
runs all built-in checks, identifies a visitor, and verifies that the visitor-data
JSON contains the same `visitorId`. Mobile and web use the same flow.

Install [Maestro](https://docs.maestro.dev/maestro-cli/how-to-install-maestro-cli)
and Java 17 or newer. CI pins Maestro 2.10.0. Create `example/.env.local` as
explained in the [example README](example/README.md). For native tests, set
`DISABLE_LOCATION_COLLECTION=true` there to avoid permission dialogs.

Start the native emulator or simulator first. From the repository root, run:

```bash
./.github/scripts/run_smoke_test.sh web
./.github/scripts/run_smoke_test.sh android emulator-5554
./.github/scripts/run_smoke_test.sh ios <simulator-udid>
```

Android requires `adb` on `PATH`. Get device IDs with `flutter devices`. The iOS
checkout directory must be named `fpjs_pro_plugin` as described above.

The web command serves the built app on port 3000 and runs headless Chromium.
Flutter web enables its accessibility DOM so Maestro can read the app's text.
The script stops its server when the test ends.
[Maestro's web support is beta](https://docs.maestro.dev/get-started/supported-platform/web-browser).

JUnit reports and failure screenshots, hierarchies, and logs are written to
`.local/maestro/<platform>`. CI uploads these as `smoke-<platform>` artifacts.
Test failures fail the job without retries or exception filtering.

### GitHub Actions secrets

The E2E smoke test workflow reads these repository secrets:

- `API_KEY` (required)
- `REGION` (optional; defaults to `us`)
- `ENDPOINTS` (optional)
- `SCRIPT_URL_PATTERN` (optional)

GitHub withholds secrets from pull requests opened from a fork, so the Web,
Android and iOS jobs are skipped there.

## Developing process

The `main` branch is locked for the push action. For proposing changes, use the standard [pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request) approach. It's recommended to discuss fixes or new functionality in the [Issues](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/issues), first.

## How to publish

We use [changesets](https://github.com/changesets/changesets) for handling release notes. If there are relevant changes,
please add a changeset via `pnpm exec changeset` (run `pnpm install` first).

After the release is created, [publish.yaml](.github%2Fworkflows%2Fpublish.yaml) workflow is triggered that publishes the package to pub.dev
