# Local Maestro experiment

Tests the normal example app on an iOS simulator without `integration_test` or a Dart VM service connection. The flow runs the example checks, identifies the device, reads the visitor-data dialog, and compares its `visitorId` with the displayed ID.

Run from the repository root:

```sh
./example/maestro-prototype/run_ios.sh
```

Requires a booted iOS simulator, Java 17 or newer, Maestro, and the example's `API_KEY` configuration in `example/.env.local`. Pass a simulator UDID as the first argument if more than one is booted. The script uses Maestro from `PATH` or the local installation at `.local/maestro/maestro/bin/maestro`. `MAESTRO_BIN` can select another installation.

The build temporarily disables location collection and restores `.env.local`. It builds `lib/main.dart`, installs the app, and lets Maestro launch it. Result artifacts stay in the ignored `.local/maestro` directory.

Three `Semantics(identifier: ...)` wrappers expose the changing result text. Existing Flutter keys remain for widget tests. See [Maestro's Flutter support](https://docs.maestro.dev/get-started/supported-platform/flutter) and [CLI installation](https://docs.maestro.dev/maestro-cli/how-to-install-maestro-cli).

## Results

The first live run passed on an iPhone 17 simulator with iOS 26.5, Maestro 2.10.0, Xcode 27.0, and Flutter master `94ae3daec2`. The full JSON text was accessible, and the ID comparison passed. Analyzer and all 12 example tests passed.

Four further fresh-launch runs passed. Each reported one test with zero failures. The flow took 9.2 to 10.7 seconds, or 31.4 to 38.2 seconds including CLI startup. Replacing the expected ID with `deliberately-wrong-id` failed only the final comparison and returned exit code 1. All preceding steps completed. Reports and command artifacts are in `.local/maestro/validation`.

This local trial does not establish CI stability or stable-Flutter compatibility. The existing CI workflow and Flutter integration tests are unchanged.
