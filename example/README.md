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
`REGION` is optional and defaults to `us`. `ENDPOINTS` is optional. Use it
for a [proxy integration](https://docs.fingerprint.com/docs/protecting-the-javascript-agent-from-adblockers).
List every identification URL you want tried, comma-separated. we recommend including the default [regional](https://docs.fingerprint.com/docs/regions) endpoint last, as a fallback.

```bash
API_KEY=your_api_key
REGION=eu
# ENDPOINTS=https://metrics.yourwebsite.com,https://api.fpjs.io
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

For the integration smoke test, see [contributing.md](../contributing.md#integration-smoke-test).
