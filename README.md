<p align="center">
  <a href="https://fingerprint.com">
    <picture>
     <source media="(prefers-color-scheme: dark)" srcset="https://fingerprintjs.github.io/home/resources/logo_light.svg" />
     <source media="(prefers-color-scheme: light)" srcset="https://fingerprintjs.github.io/home/resources/logo_dark.svg" />
     <img src="https://raw.githubusercontent.com/fingerprintjs/fingerprint-pro-server-api-go-sdk/main/res/logo_dark.svg" alt="Fingerprint logo" width="312px" />
   </picture>
  </a>
</p>
<p align="center">
  <a href="https://github.com/fingerprintjs/flutter/actions/workflows/ci.yml"><img src="https://github.com/fingerprintjs/flutter/actions/workflows/ci.yml/badge.svg" alt="Build status"></a>
  <a href="https://pub.dev/packages/fingerprint_flutter"><img src="https://img.shields.io/pub/v/fingerprint_flutter.svg"/></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/:license-mit-blue.svg?style=flat"/></a>
  <a href="https://discord.gg/39EpE2neBg"><img src="https://img.shields.io/discord/852099967190433792?style=logo&label=Discord&logo=Discord&logoColor=white" alt="Discord server"></a>
</p>

# Fingerprint Flutter

[Fingerprint](https://fingerprint.com/) is a device intelligence platform offering visitor
identification and device intelligence with industry-leading accuracy. Fingerprint Flutter SDK is an easy way to integrate Fingerprint into your Flutter
application. The plugin allows you to call the underlying native Fingerprint agents (Android, iOS, and Web) and identify devices.

## Table of contents
- [Fingerprint Flutter](#fingerprint-flutter)
  - [Table of contents](#table-of-contents)
  - [Requirements](#requirements)
  - [Dependencies](#dependencies)
  - [How to install](#how-to-install)
    - [Web platform (Optional)](#web-platform-optional)
  - [Usage](#usage)
    - [1. Create a client](#1-create-a-client)
    - [2. Identify visitors](#2-identify-visitors)
    - [Linking and tagging information](#linking-and-tagging-information)
    - [Specifying a custom timeout](#specifying-a-custom-timeout)
    - [Location data](#location-data)
    - [Web options](#web-options)
  - [Additional Resources](#additional-resources)
  - [Support and feedback](#support-and-feedback)
  - [License](#license)

## Requirements
- Flutter 3.44.0 or higher
- Dart 3.12.0 or higher
- Android 7.0 (API level 24+) or higher
- iOS 15+/tvOS 15+, Xcode 16+, Swift 6 or higher (stable releases)

We aim to keep the [Flutter compatibility policy](https://docs.flutter.dev/release/compatibility-policy).

## Dependencies
- [Fingerprint JavaScript agent](https://www.npmjs.com/package/@fingerprint/agent)
- [Fingerprint iOS](https://github.com/fingerprintjs/fingerprint-ios)
- [Fingerprint Android](https://github.com/fingerprintjs/fingerprintjs-pro-android)

iOS supports Swift Package Manager and CocoaPods. Flutter 3.44+ uses Swift Package Manager by default.

## How to install

Add `fingerprint_flutter` to the `pubspec.yaml` file in your Flutter app:

```yaml
dependencies:
  flutter:
    sdk: flutter
  ...
  fingerprint_flutter: ^4.13.1
```

Run `flutter pub get` to download and install the package.

### Web platform (Optional)

To use this plugin on the web, add the bundled v4 loader `<script>` tag to the `<head>` of your HTML template inside the `web/index.html` file:

```html
<head>
  <!-- ... -->
  <script src="assets/packages/fingerprint_flutter/web/index.js" defer></script>
</head>
```

## Usage

[Sign up](https://dashboard.fingerprint.com/signup/) and copy the public API key from **App Settings** > **API Keys**.

### 1. Create a client

Create one `Fingerprint` per API key and configuration at app startup. The constructor starts the native or web client. See the [iOS SDK](https://docs.fingerprint.com/docs/ios-sdk) and [Android quickstart](https://docs.fingerprint.com/docs/android-quickstart).

```dart
import 'package:fingerprint_flutter/fingerprint_flutter.dart';

final client = Fingerprint(
  apiKey: '<PUBLIC_API_KEY>',
  region: Region.eu, // or Region.us, Region.ap
);
```

Default to US when `region` is omitted. See [regions](https://docs.fingerprint.com/docs/regions).

`get` waits for that start. Native create builds the local client. Web `start` returns immediately; load failures surface from `get`.

To avoid ad blockers, proxy identification through a [proxy integration](https://docs.fingerprint.com/docs/protecting-the-javascript-agent-from-adblockers). Pass identification URLs as `endpoints`, first to last:

```dart
final client = Fingerprint(
  apiKey: '<PUBLIC_API_KEY>',
  region: Region.us,
  endpoints: [
    'https://metrics.yourwebsite.com',
    // Pass your regional Identification API URL default as fallback
    'https://api.fpjs.io'
  ],
);
```


### 2. Identify visitors

`get` waits for the client to be ready, returns a `FingerprintResult` or throws `FingerprintError`.

```dart
try {
  final result = await client.get();
  print(result.visitorId);
  print(result.eventId);
  print(result.suspectScore);
  print(result.sealedResult);
  print(result.cacheHit); // web only, otherwise null
} on FingerprintError catch (error) {
  print(error.code);
  print(error.message);
  print(error.eventId);
}
```

* `visitorId` is null when hidden ([Zero Trust](https://dev.fingerprint.com/docs/zero-trust-mode)). 
* `sealedResult` is set when [Sealed Results](https://dev.fingerprint.com/docs/sealed-client-results) are enabled. 
* Look up the event with `eventId` in the [Server API](https://dev.fingerprint.com/reference/getevent).

* Known error codes are constants on `FingerprintError`, such as `FingerprintError.clientTimeout`.

### Linking and tagging information

Pass information about the visitor you already have, such as account or order IDs, as `linkedId` and `tags`. See [Linking and tagging information](https://docs.fingerprint.com/docs/tagging-information).

```dart
final result = await client.get(
  linkedId: 'user_1234',
  tags: {
    'userAction': 'login',
    'analyticsId': 'UA-5555-1111-1'
  },
);
```

`tags` is a string-keyed map of JSON values. The [16 KB limit](https://docs.fingerprint.com/docs/tagging-information) applies.

### Specifying a custom timeout

Default timeout:

- iOS: 60 seconds ([iOS SDK](https://docs.fingerprint.com/docs/ios-sdk#specifying-a-custom-timeout))
- Android: none ([Android SDK](https://docs.fingerprint.com/docs/android-sdk#specifying-a-custom-timeout))
- Web: 10 seconds ([JS agent](https://docs.fingerprint.com/reference/js-agent-get-function#timeout))

```dart
final result = await client.get(timeout: const Duration(seconds: 10));
```

A timeout throws `FingerprintError` with `code` `client_timeout`.

### Location data

Location is collected only when `allowUseOfLocationData` is true on the matching platform options.

```dart
final client = Fingerprint(
  apiKey: '<PUBLIC_API_KEY>',
  android: const AndroidOptions(
    allowUseOfLocationData: true,
    locationTimeout: Duration(seconds: 10),
  ),
  ios: const IosOptions(allowUseOfLocationData: true),
);
```

On Android, identification waits up to `locationTimeout` for a fix (default 5 seconds), then continues without location. See [Android](https://docs.fingerprint.com/docs/native-android-integration#proximity-detection-for-android-devices) and [iOS](https://docs.fingerprint.com/docs/ios-sdk#using-location-data-for-proximity-detection) proximity detection.

### Web options

`WebOptions` are ignored on Android and iOS. Cache is off unless `cache` is set.

```dart
final client = Fingerprint(
  apiKey: '<PUBLIC_API_KEY>',
  web: const WebOptions(
    storageKeyPrefix: 'fp_',
    urlHashing: WebUrlHashing(path: true, query: true),
    cache: WebCache(
      storage: WebCacheStorage.sessionStorage,
      duration: WebCacheDuration.optimizeCost, // 1 hour. aggressive is 12 hours.
    ),
  ),
);
```

A custom cache duration must be a whole number of seconds, greater than zero and at most 12 hours: `WebCacheDuration.custom(const Duration(hours: 2))`. See the [JS agent start options](https://docs.fingerprint.com/reference/js-agent-start-function).

## Additional Resources
- [Fingerprint documentation](https://docs.fingerprint.com)
- [Server API](https://docs.fingerprint.com/reference/server-api)

## Support and feedback

To report problems, ask questions, or provide feedback, please
use [Issues](https://github.com/fingerprintjs/flutter/issues). If you need private support, please
email us at `oss-support@fingerprint.com`.

## License

This project is licensed under the [MIT license](https://github.com/fingerprintjs/flutter/blob/main/LICENSE).
