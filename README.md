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

# FingerprintJS Pro Flutter
### Official Flutter plugin for 100% accurate device identification, created for FingerprintJS Pro.

This plugin can be used in a Flutter application to call the native FingerprintJS Pro libraries and identify devices.

FingerprintJS Pro is a professional visitor identification service that processes all information server-side and transmits it securely to your servers using server-to-server APIs.

Retrieve an accurate, sticky and stable [FingerprintJS Pro](https://fingerprint.com/) visitor identifier in an Android or an iOS app. This library communicates with the FingerprintJS Pro API and requires an [api key](https://dev.fingerprint.com/docs). 

Native libraries used under the hood:
- [FingerprintJS Pro iOS](https://github.com/fingerprintjs/fingerprintjs-pro-ios)
- [FingerprintJS Pro Android](https://github.com/fingerprintjs/fingerprintjs-pro-android)


## Quick start

#### 1. Add `fpjs_pro_plugin` to the pubspec.yaml in your Flutter app


```yaml
dependencies:
  flutter:
    sdk: flutter
  ...
  fpjs_pro_plugin: ^1.4.0
```

Run `pub get` to download and install the package.

#### 2. Provide a configuration to the plugin

```dart
import 'package:fpjs_pro_plugin/fpjs_pro_plugin.dart';
// ...

// Initialization
class _MyAppState extends State<MyApp> {
  @override
  void initState() async {
    super.initState();
    await FpjsProPlugin.initFpjs('<apiKey>'); // insert your actual API key here
  }
  // ...
}
```

You can also configure `region` and `endpoint` in the `initFpjs` method, like below:
```dart
void doInit() async {
  await FpjsProPlugin.initFpjs('<apiKey>');
  await FpjsProPlugin.initFpjs('<apiKey>', endpoint: 'https://subdomain.domain.com');
  await FpjsProPlugin.initFpjs('<apiKey>', region: Region.eu);
}
```

For the web platform, you can use an additional `scriptUrlPattern` property to specify a custom URL for loading the JavaScript agent. This is required for proxy integrations.
```dart
void doInit() async {
  const region = Region.eu;
  await FpjsProPlugin.initFpjs(
    '<apiKey>',
    endpoint: "https://your.domain/fp_js/request_path?region=${region.stringValue}",
    region: region,
    scriptUrlPattern: 'https://your.domain/fp_js/script_path?apiKey=<apiKey>&version=<version>&loaderVersion=<loaderVersion>'
  );
}
```

#### 3. Use the plugin in your application code to identify a visitor

##### 3.1 Use the `getVisitorId` method if you need a `visitorId` only: 

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

##### 3.2 Use `getVisitorData` to get extended result

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

#### 3.3 Web platform configuration

Add `script` tag with js agent loader inside `head` tag in your html template to use `fpjs_pro_plugin` on web platform.

```html
<script src="assets/packages/fpjs_pro_plugin/web/index.js" defer></script>
```

#### 4. Use [`linkedId`](https://dev.fingerprint.com/docs/js-agent#linkedid) and [`tags`](https://dev.fingerprint.com/docs/js-agent#tag) to label identification event with additional data

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
- [FingerprintJS Pro documentation](https://dev.fingerprint.com/docs)

## License
This library is MIT licensed.
