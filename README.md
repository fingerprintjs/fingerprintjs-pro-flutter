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
  <a href="https://github.com/fingerprintjs/fingerprintjs-pro-flutter/actions/workflows/ci.yml"><img src="https://github.com/fingerprintjs/fingerprintjs-pro-flutter/actions/workflows/ci.yml/badge.svg" alt="Build status"></a>
  <a href="https://pub.dev/packages/fpjs_pro_plugin"><img src="https://img.shields.io/pub/v/fpjs_pro_plugin.svg"/></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/:license-mit-blue.svg?style=flat"/></a>
  <a href="https://discord.gg/39EpE2neBg"><img src="https://img.shields.io/discord/852099967190433792?style=logo&label=Discord&logo=Discord&logoColor=white" alt="Discord server"></a>
</p>

# Fingerprint Pro Flutter

[Fingerprint](https://fingerprint.com/) is a device intelligence platform offering visitor
identification and device intelligence with industry-leading accuracy. Fingerprint Flutter SDK is an easy way to integrate Fingerprint into your Flutter
application. The plugin allows you to call the underlying native Fingerprint agents (Android, iOS and Web) and identify devices.

## Table of contents
- [Fingerprint Pro Flutter](#fingerprint-pro-flutter)
  - [Table of contents](#table-of-contents)
  - [Requirements](#requirements)
  - [Dependencies](#dependencies)
  - [How to install](#how-to-install)
    - [Web platform (Optional)](#web-platform-optional)
  - [Usage](#usage)
    - [1. Configure and initialize the plugin](#1-configure-and-initialize-the-plugin)
    - [2. Identify visitors](#2-identify-visitors)
    - [Linking and tagging information](#linking-and-tagging-information)
    - [Specifying a custom timeout](#specifying-a-custom-timeout)
  - [Additional Resources](#additional-resources)
  - [Support and feedback](#support-and-feedback)
  - [License](#license)

## Requirements
- Flutter 3.13 or higher
- Dart 3.3 or higher
- Android 5.0 (API level 21+) or higher
- iOS 13+/tvOS 15+, Swift 5.7 or higher (stable releases)

We aim to keep the [Flutter compatibility policy](https://docs.flutter.dev/release/compatibility-policy).

## Dependencies
- [Fingerprint JavaScript agent](https://www.npmjs.com/package/@fingerprintjs/fingerprintjs-pro)
- [Fingerprint iOS](https://github.com/fingerprintjs/fingerprintjs-pro-ios)
- [Fingerprint Android](https://github.com/fingerprintjs/fingerprintjs-pro-android)

## How to install

Add `fpjs_pro_plugin` to the `pubspec.yaml` file in your Flutter app:

```yaml
dependencies:
  flutter:
    sdk: flutter
  ...
  fpjs_pro_plugin: ^3.3.2
```

Run `flutter pub get` to download and install the package.

### Web platform (Optional)

To use this plugin on the web, add the JavaScript agent loader `<script>` tag to the `<head>` of your HTML template inside the `web/index.html` file:

```html
<head>
  <!-- ... -->
  <script src="assets/packages/fpjs_pro_plugin/web/index.js" defer></script>
</head>
```

## Usage

To identify visitors, you need to [sign up for a Fingerprint account](https://dashboard.fingerprintjs.com/signup/) (there is a free trial available).

- Go to [the Fingerprint Pro dashboard](https://dashboard.fingerprint.com/).
- Navigate to **App Settings** > **API Keys** to find your _Public_ API Key.

### 1. Configure and initialize the plugin

Initialize the Fingerprint Flutter plugin inside a [StatefulWidget](https://api.flutter.dev/flutter/widgets/StatefulWidget-class.html), for example, in the `initState` method. 

Use the [Public API key](https://dev.fingerprint.com/docs/quick-start-guide#2-get-your-api-key) and [region](https://dev.fingerprint.com/docs/regions) of your Fingerprint workspace (US region is used by default).

```dart
import 'package:fpjs_pro_plugin/fpjs_pro_plugin.dart';
import 'package:fpjs_pro_plugin/region.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

// Initialization
class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    doInit();
  }
  
  void doInit() async {
    await FpjsProPlugin.initFpjs(
      '<PUBLIC_API_KEY>', // insert your API key here
      region: Region.us // or Region.eu, Region.ap
    );
  }
  // ...
}
```

To avoid ad blockers, we recommend proxying requests from your application to Fingerprint servers through one of our proxy integrations. See [Evading ad blockers with proxy integrations](https://dev.fingerprint.com/docs/evading-adblockers) for more information.

To use a proxy integration, you can configure `endpoint`, `scriptUrlPattern` and their fallbacks.

```dart
 void doInit() async {
    await FpjsProPlugin.initFpjs(
      '<PUBLIC_API_KEY>',
      region: Region.us,
      // Your proxy integration identification endpoint
      endpoint: 'https://metrics.yourwebsite.com',
      endpointFallbacks: ['https://api.fpjs.io'], // region-specific fallback
      // Your proxy integration script URL pattern
      // Only necessary for the web platform
      scriptUrlPattern: 'https://metrics.yourwebsite.com/web/v<version>/<apiKey>/loader_v<loaderVersion>.js',
      scriptUrlPatternFallbacks: [
        'https://fpjscdn.net/v<version>/<apiKey>/loader_v<loaderVersion>.js',
      ],
    );
  }
```

### 2. Identify visitors

Use `getVisitorId` to get just the visitor ID, or `getVisitorData` to get the identification response object.

```dart
import 'package:fpjs_pro_plugin/fpjs_pro_plugin.dart';
import 'package:fpjs_pro_plugin/region.dart';
import 'package:fpjs_pro_plugin/error.dart';
// ...

class _MyAppState extends State<MyApp> {
  void identify() async {
    try {
      var visitorId = await FpjsProPlugin.getVisitorId();
      var visitorData = await FpjsProPlugin.getVisitorData();

      print('Visitor ID: $visitorId');
      print('Visitor data: $visitorData');
    } on FingerprintProError catch (e) {
      // Process the error
      print('Error identifying visitor: $e');
      // See lib/error.dart to get more information about error types
    }
  }
}
```


By default, `getVisitorData()` will return a short response (`FingerprintJSProResponse`).
Pass `extendedResponseFormat: true` to the `initFpjs` function to get an extended response (`FingerprintJSProExtendedResponse`) with .

```dart
void doInit() async {
  await FpjsProPlugin.initFpjs('<PUBLIC_API_KEY>', extendedResponseFormat: true);
}
```

### Linking and tagging information

The `visitorId` provided by Fingerprint Identification is especially useful when combined with information you already know about your users, for example, account IDs, order IDs, etc. To learn more about various applications of the `linkedId` and `tag`, see [Linking and tagging information](https://dev.fingerprint.com/docs/tagging-information).

```dart
void identify() async {
  const tags = {
    'userAction': 'login',
    'analyticsId': 'UA-5555-1111-1'
  };
  const linkedId = 'user_1234';

  visitorId = await FpjsProPlugin.getVisitorId(linkedId: linkedId, tags: tags);
  deviceData = await FpjsProPlugin.getVisitorData(linkedId: linkedId, tags: tags);
}
```

### Specifying a custom timeout

*Default timeout value:*
- iOS: 60 seconds
- Android: not specified
- Web: 10 seconds

You can override the default timeout with a custom value of your choice. If the `getVisitorId()` or `getVisitorData()` call does not complete within the specified (or default) timeout, you will receive a `ClientTimeoutError` error.

```dart
void identify() async {
  visitorId = await FpjsProPlugin.getVisitorId(timeoutMs: 10000);
  deviceData = await FpjsProPlugin.getVisitorData(timeoutMs: 10000);
}
```

## Additional Resources
- [Fingerprint Pro documentation](https://dev.fingerprint.com/docs)
- [Server API](https://dev.fingerprint.com/reference/server-api)

## Support and feedback

To report problems, ask questions or provide feedback, please
use [Issues](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/issues). If you need private support, please
email us at `oss-support@fingerprint.com`.

## License

This project is licensed under the [MIT license](https://github.com/fingerprintjs/fingerprintjs-pro-flutter/blob/main/LICENSE).
