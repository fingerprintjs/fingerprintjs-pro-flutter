// Public entry point: the `Fingerprint` client and its options.
// https://docs.fingerprint.com/docs/flutter
import 'dart:async';

import 'package:fingerprint_flutter/options.dart';
import 'package:fingerprint_flutter/region.dart';
import 'package:fingerprint_flutter/src/fingerprint_platform_interface.dart';
import 'package:fingerprint_flutter/src/fingerprint_result.dart';
import 'package:fingerprint_flutter/src/validation.dart';

export 'package:fingerprint_flutter/error.dart';
export 'package:fingerprint_flutter/options.dart';
export 'package:fingerprint_flutter/region.dart';
export 'package:fingerprint_flutter/result.dart';

// Update it on each release
const pluginVersion = '4.13.1';

/// Identification client. Create one per public API key and configuration.
///
/// The constructor starts the client early, so create it at app startup and
/// keep it:
/// - iOS: starts location collection, for better location precision
/// - Android: loads the SDK, so the first [get] is faster. Location is
///   collected during [get].
/// - Web: starts loading the JS agent
///
/// [get] does not depend on that start and is where create or load failures
/// surface. Every get carries the full config, so two clients stay
/// independent.
///
/// On Android and iOS, the constructor throws `FlutterError` if the Flutter
/// binding does not exist yet. In `main()` before `runApp()`, call
/// `WidgetsFlutterBinding.ensureInitialized()` first.
/// https://docs.fingerprint.com/docs/ios-sdk
/// https://docs.fingerprint.com/docs/android-sdk
/// https://docs.fingerprint.com/reference/js-agent-start-function
class Fingerprint {
  /// Public API key for this client.
  final String apiKey;

  /// Workspace region. Android and iOS default to US when omitted. Web
  /// infers it from the API key.
  /// https://docs.fingerprint.com/reference/js-agent-start-function
  final Region? region;

  /// Identification endpoints, first to last. Null, empty, or only empty
  /// strings uses the regional default. Empty strings in the list are dropped.
  ///
  /// It's recommended to include the default API URL for your [region](https://docs.fingerprint.com/docs/regions) last, as a fallback.
  /// https://docs.fingerprint.com/docs/protecting-the-javascript-agent-from-adblockers
  final List<String>? endpoints;

  /// Android-only settings. Ignored on iOS and web.
  final AndroidOptions? android;

  /// iOS-only settings. Ignored on Android and web.
  final IosOptions? ios;

  /// Web-only settings. Ignored on Android and iOS.
  final WebOptions? web;

  late final FingerprintConfig _config;

  Fingerprint({
    required this.apiKey,
    this.region,
    List<String>? endpoints,
    this.android,
    this.ios,
    this.web,
  }) : endpoints = _normalizeEndpoints(endpoints) {
    _config = FingerprintConfig(
      apiKey: apiKey,
      pluginVersion: pluginVersion,
      region: region,
      endpoints: this.endpoints,
      android: android,
      ios: ios,
      web: web,
    );
    // Warm-up only: iOS location, Android SDK loading, the web bundle.
    // - get does not wait for it. Platform get creates the client itself.
    // - A failed warm-up does not break the client. Real create errors
    //   surface from get.
    // - A missing Flutter binding throws FlutterError here, see
    //   FingerprintNative.create.
    // - ignore() so a failure is not an unhandled async error.
    FingerprintPlatform.instance.create(_config).ignore();
  }

  /// Identifies the current visitor or device.
  ///
  /// [tags] is a string-keyed map of JSON-compatible values. The same map
  /// is forwarded on every platform, including JSON null.
  /// https://docs.fingerprint.com/docs/tagging-information
  ///
  /// [timeout] must not be negative. Null uses the platform default.
  Future<FingerprintResult> get({
    Map<String, Object?>? tags,
    String? linkedId,
    Duration? timeout,
  }) {
    // Not `async`, so ArgumentError throws now, not as a Future error.
    validateTags(tags);
    validateTimeout(timeout);
    return FingerprintPlatform.instance.get(
      _config,
      tags: tags,
      linkedId: linkedId,
      timeout: timeout,
    );
  }
}

/// Empty strings would become a missing native primary and invent the region
/// URL as the first try. Drop them, then treat an empty list as null.
List<String>? _normalizeEndpoints(List<String>? endpoints) {
  if (endpoints == null) {
    return null;
  }
  final kept = [
    for (final url in endpoints)
      if (url.isNotEmpty) url,
  ];
  if (kept.isEmpty) {
    return null;
  }
  return List<String>.unmodifiable(kept);
}
