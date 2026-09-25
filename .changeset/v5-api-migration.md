---
"fingerprint_flutter": major
---

Migrated the SDK to Fingerprint API v4 and replaced the static `FpjsProPlugin` API with an instance `Fingerprint` client. This is a breaking change on every platform (web, iOS, Android). The package is now `fingerprint_flutter` (was `fpjs_pro_plugin`).

**Renamed API**

- Package `fpjs_pro_plugin` → `fingerprint_flutter`. Import `package:fingerprint_flutter/fingerprint_flutter.dart`.
- `FpjsProPlugin.initFpjs(...)` → `Fingerprint(...)`. The constructor is synchronous and starts the client. Identification failures surface on `get`.
- `getVisitorId` and `getVisitorData` are removed. Call `get({tags, linkedId, timeout})`.
- Web loader script: `assets/packages/fpjs_pro_plugin/web/index.js` → `assets/packages/fingerprint_flutter/web/index.js`.

**Single get options**

- `getVisitorData(tags: ..., linkedId: ..., timeoutMs: 5000)` → `get(tags: ..., linkedId: ..., timeout: Duration(seconds: 5))`.
- Timeouts are `Duration`, not `int` milliseconds.

**Grouped constructor options**

- Platform-only options are nested: `android` (`allowUseOfLocationData`, `locationTimeout`), `ios` (`allowUseOfLocationData`), `web` (`storageKeyPrefix`, `urlHashing`, `cache`).
- `locationTimeoutMillisAndroid` moves to `android.locationTimeout` (`Duration`).
- `endpoint` + `endpointFallbacks` are replaced by a single `endpoints` list.
- `scriptUrlPattern` and `scriptUrlPatternFallbacks` are removed. The bundled v4 loader script is the web agent.
- `extendedResponseFormat` is removed. v4 always returns the flat result.

**Result fields**

- The response is `FingerprintResult`: `eventId`, `visitorId?`, `suspectScore?`, `sealedResult?`, `cacheHit?` (web only).
- `requestId` is replaced by `eventId`. `confidence` / `confidenceScore` are removed. `suspectScore` is a new optional Smart Signals value.
- Nested extended fields (`ipLocation`, `firstSeenAt`, and the rest) and the `FingerprintJSProResponse` / `FingerprintJSProExtendedResponse` types are removed.
- `visitorId` is null when hidden ([Zero Trust](https://dev.fingerprint.com/docs/zero-trust-mode)). Empty native values become null.

**Single error type**

- The `FingerprintProError` subclasses (`TooManyRequestError`, `ClientTimeoutError`, and the rest) are replaced by a single `FingerprintError` (`code`, `message?`, `eventId?`).
- Discriminate on `error.code`, for example `FingerprintError.tooManyRequests`.
- Network failures report `code: 'network_error'` on all platforms.

**Web**

- The web implementation uses `@fingerprint/agent` v4, bundled in this package. There is no extra npm peer dependency.
- Caching is available only on web and is off by default. Pass `web: WebOptions(cache: ...)` to enable it.

```dart
final fp = Fingerprint(
  apiKey: '<PUBLIC_API_KEY>',
  region: Region.eu,
  web: const WebOptions(
    cache: WebCache(
      storage: WebCacheStorage.sessionStorage,
      duration: WebCacheDuration.optimizeCost,
    ),
  ),
);
```

**iOS**

- The new version floor is iOS 15 / tvOS 15, Xcode 16, Swift 6.

**Android**

- The new version floor is Android 7.0 (API 24+).
- The plugin no longer applies the Kotlin Gradle plugin, so it builds under AGP 9. Apps still on AGP 8 need Kotlin Gradle plugin 2.2.20 or newer. The v4 Android SDK already requires that.

**Requirements**

- Flutter 3.44.0 and Dart 3.12.0.

## Migration

**Package**

```diff
  dependencies:
    flutter:
      sdk: flutter
-   fpjs_pro_plugin: ^4.13.1
+   fingerprint_flutter: ^5.0.0
```

```diff
- import 'package:fpjs_pro_plugin/fpjs_pro_plugin.dart';
+ import 'package:fingerprint_flutter/fingerprint_flutter.dart';
```

**Client**

```diff
- await FpjsProPlugin.initFpjs('<PUBLIC_API_KEY>', region: Region.eu);
- final visitorId = await FpjsProPlugin.getVisitorId();
- final data = await FpjsProPlugin.getVisitorData();
+ final fp = Fingerprint(apiKey: '<PUBLIC_API_KEY>', region: Region.eu);
+ final result = await fp.get();
+ result.visitorId
+ result.eventId
```

**Identify**

```diff
- await FpjsProPlugin.getVisitorData(
-   tags: {'userAction': 'login'},
-   linkedId: 'user_1234',
-   timeoutMs: 5000,
- );
+ await fp.get(
+   tags: {'userAction': 'login'},
+   linkedId: 'user_1234',
+   timeout: const Duration(seconds: 5),
+ );
```

```diff
- data.requestId
- data.confidenceScore.score
+ result.eventId
+ result.suspectScore
```

**Constructor options**

```diff
- await FpjsProPlugin.initFpjs(
-   '<PUBLIC_API_KEY>',
-   region: Region.eu,
-   endpoint: 'https://metrics.example.com',
-   endpointFallbacks: ['https://metrics2.example.com'],
-   allowUseOfLocationData: true,
-   locationTimeoutMillisAndroid: 5000,
- );
+ final fp = Fingerprint(
+   apiKey: '<PUBLIC_API_KEY>',
+   region: Region.eu,
+   endpoints: [
+     'https://metrics.example.com',
+     'https://metrics2.example.com',
+   ],
+   android: const AndroidOptions(
+     allowUseOfLocationData: true,
+     locationTimeout: Duration(seconds: 5),
+   ),
+   ios: const IosOptions(allowUseOfLocationData: true),
+ );
```

**Errors**

```diff
  try {
-   await FpjsProPlugin.getVisitorData();
- } on FingerprintProError catch (error) {
-   if (error is TooManyRequestError) {
+   await fp.get();
+ } on FingerprintError catch (error) {
+   if (error.code == FingerprintError.tooManyRequests) {
      // handle rate limiting
    }
  }
```

**Web script**

```diff
- <script src="assets/packages/fpjs_pro_plugin/web/index.js" defer></script>
+ <script src="assets/packages/fingerprint_flutter/web/index.js" defer></script>
```
