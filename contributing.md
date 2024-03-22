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

The library is automatically released on every push to the main branch if there are relevant changes using [semantic-release](https://github.com/semantic-release/semantic-release) with following plugins:

- [@semantic-release/commit-analyzer](https://github.com/semantic-release/commit-analyzer)
- [@semantic-release/release-notes-generator](https://github.com/semantic-release/release-notes-generator)
- [@semantic-release/changelog](https://github.com/semantic-release/changelog)
- [@semantic-release/github](https://github.com/semantic-release/github)
- [@semantic-release/exec](https://github.com/semantic-release/exec)

The workflow must be approved by one of the maintainers, first.
The release configuration can be found in [.releaserc](.releaserc) file.

After the release is created, [publish.yaml](.github%2Fworkflows%2Fpublish.yaml) workflow is triggered that publishes the package to pub.dev 