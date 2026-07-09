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

## How to publish

We use [changesets](https://github.com/changesets/changesets) for handling release notes. If there are relevant changes,
please add a changeset via `pnpm exec changeset` (run `pnpm install` first).

After the release is created, [publish.yaml](.github%2Fworkflows%2Fpublish.yaml) workflow is triggered that publishes the package to pub.dev 