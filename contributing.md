# Contributing to FingerprintJS Pro Flutter integration

## Development Environment

Before starting work on the repository please configure the environment and emulators.
1. Install Flutter using [instruction for your OS](https://docs.flutter.dev/get-started/install).
2. Follow official recommendations [about setting up IDE](https://docs.flutter.dev/get-started/editor?tab=androidstudio).

## Development playground

In the `example` folder you can find the demo application. Read the [instruction](https://docs.flutter.dev/get-started/test-drive?tab=androidstudio) on how to start the example app.

To build the iOS example with Swift Package Manager, clone this repo into a folder named `fpjs_pro_plugin` (the Dart package name). Flutter uses that folder name as the SwiftPM package identity ([flutter#186881](https://github.com/flutter/flutter/issues/186881)). A clone named `fingerprintjs-pro-flutter` will fail. pub.dev installs are unaffected.

This is temporary. Drop this note and the CI `path:` workaround once [flutter#188647](https://github.com/flutter/flutter/pull/188647) reaches stable.

## Testing

For running tests just call `flutter test`.

### Integration smoke test

The smoke test follows the manual example flow: it waits for the Fingerprint
agent to be ready, runs the built-in checks, identifies a visitor, and verifies
that visitor data is available.

First create `example/.env.local` as described in the
[example README](example/README.md), and start the target emulator or simulator
when testing a native platform. Then from the `example` folder run one of:

```bash
# replace the device with the ID from `flutter devices`
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/smoke_test.dart \
  -d emulator-5554
```

`flutter test integration_test/smoke_test.dart` also works and is quicker, but
on an iOS simulator it intermittently never launches the app and then waits
forever ([flutter#153433](https://github.com/flutter/flutter/issues/153433)),
so CI uses `flutter drive` everywhere.

Chrome also requires a matching
[ChromeDriver](https://developer.chrome.com/docs/chromedriver) on `PATH`. Start
it in one terminal:

```bash
chromedriver --port=4444
```

Then run the web smoke test in another:

```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/smoke_test.dart \
  --web-port=3000 \
  -d chrome
```

Native automation should also add the following setting to `.env.local`:

```bash
DISABLE_LOCATION_COLLECTION=true
```

This prevents Android and iOS permission dialogs from blocking unattended
tests. Leave it absent or set it to `false` for normal manual runs; location
collection remains enabled by default.

### GitHub Actions secrets

The E2E smoke test workflow reads these repository secrets:

- `API_KEY` (required)
- `REGION` (optional; defaults to `us`)
- `ENDPOINT` (optional)
- `SCRIPT_URL_PATTERN` (optional)

GitHub withholds secrets from pull requests opened from a fork, so the Web,
Android and iOS jobs are skipped there.

## Developing process

The `main` branch is locked for the push action. For proposing changes, use the standard [pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request) approach. It's recommended to discuss fixes or new functionality in the [Issues](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/issues), first.

## How to publish

We use [changesets](https://github.com/changesets/changesets) for handling release notes. If there are relevant changes,
please add a changeset via `pnpm exec changeset` (run `pnpm install` first).

After the release is created, [publish.yaml](.github%2Fworkflows%2Fpublish.yaml) workflow is triggered that publishes the package to pub.dev 