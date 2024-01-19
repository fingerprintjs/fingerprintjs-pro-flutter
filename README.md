<p align="center">
  <a href="https://fingerprint.com">
    <picture>
     <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/fingerprintjs/fingerprintjs-pro-flutter/main/res/logo_light.svg" />
     <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/fingerprintjs/fingerprintjs-pro-flutter/main/res/logo_dark.svg" />
     <img src="https://raw.githubusercontent.com/fingerprintjs/fingerprintjs-pro-flutter/main/res/logo_dark.svg" alt="Fingerprint logo" width="312px" />
   </picture>
  </a>
</p>
<p align="center">
  <a href="https://github.com/fingerprintjs/fingerprintjs-pro-flutter/actions/workflows/ci.yml">
    <img src="https://github.com/fingerprintjs/fingerprintjs-pro-flutter/actions/workflows/ci.yml/badge.svg" alt="Build status">
  </a>
  <a href="https://pub.dev/packages/fpjs_pro_plugin">
    <img src="https://img.shields.io/pub/v/fpjs_pro_plugin.svg"/>
  </a>
  <a href="https://opensource.org/licenses/MIT">
    <img src="https://img.shields.io/:license-mit-blue.svg?style=flat"/>
  </a>
  <a href="https://discord.gg/39EpE2neBg">
    <img src="https://img.shields.io/discord/852099967190433792?style=logo&label=Discord&logo=Discord&logoColor=white" alt="Discord server">
  </a>
</p>

# Fingerprint Pro Flutter
[Fingerprint](https://fingerprint.com/) is a device intelligence platform offering 99.5% accurate visitor
identification. Fingerprint Pro Flutter SDK is an easy way to integrate Fingerprint Pro into your Flutter
application to call the native Fingerprint Pro libraries (Android, iOS and Web) and identify devices.

## Table of contents
* [Requirements](#requirements)
* [Dependencies](#dependencies)
* [How to install](#how-to-install)
* [Usage](#usage)
* [Additional Resources](#additional-resources)
* [Support and feedback](#support-and-feedback)
* [License](#license)

## Requirements
- Flutter 2.5.0 or higher
- Android 5.0 (API level 21+) or higher
- iOS 13+/tvOS 15+, Swift 5.7 or higher (stable releases)

We aim to keep the [Flutter compatibility policy](https://docs.flutter.dev/release/compatibility-policy).

## Dependencies
- [Fingerprint Pro iOS](https://github.com/fingerprintjs/fingerprintjs-pro-ios)
- [Fingerprint Pro Android](https://github.com/fingerprintjs/fingerprintjs-pro-android)

## How to install
Add `fpjs_pro_plugin` to the pubspec.yaml in your Flutter app:

```yaml
dependencies:
  flutter:
    sdk: flutter
  ...
  fpjs_pro_plugin: ^2.1.1
```

Run `pub get` to download and install the package.

### Web platform

Add a `<script>` tag with the JS agent loader inside the `<head>` tag in your HTML template to use `fpjs_pro_plugin`:

```html
<script src="assets/packages/fpjs_pro_plugin/web/index.js" defer></script>
```

## Usage
To identify visitors, you need a Fingerprint Pro account (you can [sign up for free](https://dashboard.fingerprintjs.com/signup/)).

- Go to [the Fingerprint Pro dashboard](https://dashboard.fingerprint.com/).
- Navigate to **App Settings** > **API Keys** to find your _Public_ API Key.

### 1. Configure the plugin

```dart
import 'package:fpjs_pro_plugin/fpjs_pro_plugin.dart';
// ...

// Initialization
class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    doInit();
  }
  
  void doInit() async {
    await FpjsProPlugin.initFpjs(
      '<apiKey>' // insert your actual API key here
    );
  }
  // ...
}
```

You can also configure `region` and `endpoint` in the `initFpjs` method, like below. For the web platform, you can use an additional `scriptUrlPattern` property to specify a custom URL for loading the JavaScript agent. This is required for proxy integrations.
```dart
void doInit() async {
  await FpjsProPlugin.initFpjs(
    '<apiKey>',
    endpoint: 'https://subdomain.domain.com',
    region: Region.eu, // or Region.ap, Region.us
    scriptUrlPattern: 'https://your.domain/fp_js/script_path?apiKey=<apiKey>&version=<version>&loaderVersion=<loaderVersion>'
  );
}
```

### 2. Use the plugin in your application code to identify a visitor

#### 2.1 Use the `getVisitorId` method if you only need a `visitorId`: 

```dart
import 'package:fpjs_pro_plugin/fpjs_pro_plugin.dart';
// ...

// Initialization
class _MyAppState extends State<MyApp> {
  // ...
  // Usage
  void identify() async {
    try {
      visitorId = await FpjsProPlugin.getVisitorId() ?? 'Unknown';
      // use the visitor id
    } on FingerprintProError catch (e) {
      // process an error somehow
      // check lib/error.dart to get more info about error types
    }
  }
}
```

#### 2.2 Use `getVisitorData` to get extended result

```dart
import 'package:fpjs_pro_plugin/fpjs_pro_plugin.dart';
// ...

// Initialization
class _MyAppState extends State<MyApp> {
  // ...
  // Usage
  void identify() async {
    try {
      deviceData = await FpjsProPlugin.getVisitorData();
      // use the visitor id
    } on FingerprintProError catch (e) {
      // process an error somehow
      // check lib/error.dart to get more info about error types
    }
  }
}
```

By default `getVisitorData()` will return a short response with the `FingerprintJSProResponse` type.
Provide `extendedResponseFormat=true` to the `initFpjs` function to get extended result of `FingerprintJSProExtendedResponse` type.

```dart
void doInit() async {
  await FpjsProPlugin.initFpjs('<apiKey>', extendedResponseFormat: true);
}
```

### 3. Use [`linkedId`](https://dev.fingerprint.com/docs/js-agent#linkedid) and [`tags`](https://dev.fingerprint.com/docs/js-agent#tag) to label the identification event with additional data

```dart
void doIdentification() async {
  const tags = {
    'foo': 'bar',
    'numberField': 1234,
    'objectField': {
      'booleanSubfield': true,
      'arraySubfield': [1, 2, 3]
    },
    'booleanField': false
  };
  const linkedId = 'custom_linked_id';

  visitorId = await FpjsProPlugin.getVisitorId(linkedId: linkedId, tags: tags);
  deviceData = await FpjsProPlugin.getVisitorData(linkedId: linkedId, tags: tags);
}
```

## Additional Resources
- [Server-to-Server API](https://dev.fingerprint.com/docs/server-api)
- [Fingerprint Pro documentation](https://dev.fingerprint.com/docs)

## Support and feedback

To report problems, ask questions or provide feedback, please
use [Issues](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/issues). If you need private support, please
email us at `oss-support@fingerprint.com`.

## License
This project is licensed under the [MIT license](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/blob/main/LICENSE).
