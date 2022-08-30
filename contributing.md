# Contributing to FingerprintJS Pro Flutter integration

## Development Environment

Before starting work on the repository please configure the environment and emulators.
1. Install Flutter using [instruction for your OS](https://docs.flutter.dev/get-started/install).
2. Follow official recommendations [about setting up IDE](https://docs.flutter.dev/get-started/editor?tab=androidstudio).

## Development playground

In the `example` folder you can find the demo application. Read the [instruction](https://docs.flutter.dev/get-started/test-drive?tab=androidstudio) on how to start the example app.

## Testing

For running tests just call `flutter test`.

## Developing process

The `main` branch is locked for the push action. For proposing changes, use the standard [pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request) approach. It's recommended to discuss fixes or new functionality in the [Issues](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/issues), first.

## Preparing to the publishing new release

1. Update version in `pubspec.yaml`
2. Update version in `ios/fpjs_pro_plugin.podspec`
3. Update version in `android/build.gradle`
4. Update version in `README.md` in adding instruction
5. Update `pluginVersion` in `fpjs_pro_plugin.dart` that used for the integration info
6. Update library version for the example lock files (TODO: provide correct scenario)
7. Add information about the release to the `CHANGELOG.md`