---
"fingerprint_flutter": major
---

Migrated the SDK to Fingerprint API v4. This is a breaking change on every platform.

**Requirements**

- Flutter 3.44.0 and Dart 3.12.0.
- Android 7.0 (API 24+). Native SDK `4.0.0`. The plugin no longer applies the Kotlin Gradle plugin, so it builds under AGP 9. Apps on AGP 8 need Kotlin Gradle plugin 2.2.20 or newer.
- iOS 15 / tvOS 15, Xcode 16, Swift 6. Native SDK 4.x (`Fingerprint-iOS`).
- Web uses the bundled `@fingerprint/agent` v4. There is no extra npm peer dependency.

**Package**

`fpjs_pro_plugin` is now `fingerprint_flutter`.

```diff
- fpjs_pro_plugin: ^4.13.1
+ fingerprint_flutter: ^5.0.0

- import 'package:fpjs_pro_plugin/fpjs_pro_plugin.dart';
+ import 'package:fingerprint_flutter/fingerprint_flutter.dart';
```

**API**

- Static `FpjsProPlugin.initFpjs` / `getVisitorId` / `getVisitorData` are replaced by an instance `Fingerprint` client with `get({tags, linkedId, timeout})`.
- The constructor is synchronous and starts the client. Identification failures surface on `get`. On Android and iOS, the constructor throws if the Flutter binding does not exist yet, so call `WidgetsFlutterBinding.ensureInitialized()` first, as with `initFpjs`.
- Timeouts are `Duration`. `endpoint` + `endpointFallbacks` become one `endpoints` list. Platform options nest under `android`, `ios`, and `web`.
- `scriptUrlPattern`, `scriptUrlPatternFallbacks`, and `extendedResponseFormat` are removed.

```diff
- await FpjsProPlugin.initFpjs(
-   '<PUBLIC_API_KEY>',
-   region: Region.eu,
-   endpoint: 'https://metrics.example.com',
-   endpointFallbacks: ['https://metrics2.example.com'],
-   allowUseOfLocationData: true,
-   locationTimeoutMillisAndroid: 5000,
-   scriptUrlPattern:
-       'https://metrics.example.com/web/v<version>/<apiKey>/loader_v<loaderVersion>.js',
- );
- final data = await FpjsProPlugin.getVisitorData(
-   tags: {'userAction': 'login'},
-   linkedId: 'user_1234',
-   timeoutMs: 5000,
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
+   web: const WebOptions(
+     cache: WebCache(
+       storage: WebCacheStorage.sessionStorage,
+       duration: WebCacheDuration.optimizeCost,
+     ),
+   ),
+ );
+ final result = await fp.get(
+   tags: {'userAction': 'login'},
+   linkedId: 'user_1234',
+   timeout: const Duration(seconds: 5),
+ );
+ print(result.visitorId);
+ print(result.eventId);
+ print(result.suspectScore);
```

**Result**

- `FingerprintResult`: `eventId`, `visitorId?`, `suspectScore?`, `sealedResult?`, `cacheHit?` (web only).
- `requestId` is now `eventId`. `confidence` / `confidenceScore` and the extended types (`ipLocation`, `firstSeenAt`, and the rest) are gone.
- `visitorId` is null when hidden ([Zero Trust](https://dev.fingerprint.com/docs/zero-trust-mode)).

**Errors**

One `FingerprintError` (`code`, `message?`, `eventId?`). Discriminate on `error.code`. Network failures report `code: 'network_error'` on all platforms.

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

**Web**

Caching is off unless you pass `web: WebOptions(cache: ...)`.

```diff
- <script src="assets/packages/fpjs_pro_plugin/web/index.js" defer></script>
+ <script src="assets/packages/fingerprint_flutter/web/index.js" defer></script>
```
