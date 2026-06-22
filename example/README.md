# Example project using `fpjs_pro_plugin`

Demonstrates how to use the `fpjs_pro_plugin` plugin.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Running the example project

### 1. Install dependencies

```bash
cd example
flutter pub get
```

### 2. Define environment variables

1. Create a `.env.local` file by copying the checked-in `.env` template:

```bash
cp .env .env.local
```

The project will not compile if the `.env.local` file is not present.

2. Add your environment variables to `.env.local`. `API_KEY` is required.
`REGION` is optional and defaults to `us`. `ENDPOINT` and
`SCRIPT_URL_PATTERN` are only needed for workspaces using custom endpoints.

```bash
API_KEY=your_api_key
REGION=eu
# ENDPOINT=https://your-endpoint.example
# SCRIPT_URL_PATTERN=https://your-cdn.example/path
```

### 3. Run the example project

You can run the project in Chrome like this:

```bash
flutter run -d chrome --web-port 3000
```

For running the project in iOS or Android, you will need to have a physical device or an emulator running. See the Flutter documentation for more information: 

* [Configure iOS development (MacOS)](https://docs.flutter.dev/get-started/install/macos/mobile-ios)
* [Configure Android development (MacOS)](https://docs.flutter.dev/get-started/install/macos/mobile-android)
* [Configure Android development (Windows)](https://docs.flutter.dev/get-started/install/windows/mobile)

## Running the integration smoke test

The smoke test follows the manual example flow: it waits for the Fingerprint
agent to be ready, runs the built-in checks, identifies a visitor, and verifies
that an extended result is available.

First create `.env.local` as described above and start the target emulator or
simulator when testing a native platform. Then run one of:

```bash
# Android (replace with the ID from `flutter devices`)
flutter test integration_test/smoke_test.dart -d emulator-5554

# iOS (replace with the simulator ID from `flutter devices`)
flutter test integration_test/smoke_test.dart -d <ios-simulator-id>
```

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
  -d chrome
```

Native automation should also add the following setting to `.env.local`:

```bash
DISABLE_LOCATION_COLLECTION=true
```

This prevents Android and iOS permission dialogs from blocking unattended
tests. Leave the setting absent or set it to `false` for normal manual runs;
location collection remains enabled by default.

### GitHub Actions secrets

The pull request E2E workflow reads these repository secrets:

- `API_KEY` (required)
- `REGION` (optional; defaults to `us`)
- `ENDPOINT` (optional)
- `SCRIPT_URL_PATTERN` (optional)

If `API_KEY` is unavailable, including on pull requests from forks, the
secret-backed Chrome, Android, and iOS jobs are skipped.
