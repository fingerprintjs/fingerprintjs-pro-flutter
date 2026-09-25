import 'dart:async';

import 'package:fpjs_pro_plugin/options.dart';
import 'package:fpjs_pro_plugin/region.dart';
import 'package:fpjs_pro_plugin/src/fingerprint_platform_interface.dart';
import 'package:fpjs_pro_plugin/src/fingerprint_result.dart';

export 'package:fpjs_pro_plugin/error.dart';
export 'package:fpjs_pro_plugin/options.dart';
export 'package:fpjs_pro_plugin/region.dart';
export 'package:fpjs_pro_plugin/result.dart';

// Update it on each release
const pluginVersion = '4.13.1';

/// Identification client. Create one per public API key and configuration.
///
/// The constructor starts the native or web client. [get] waits for that
/// start and is where create or load failures surface. Every get carries the
/// full config, so two clients stay independent.
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
  late final Future<void> _created;

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
    // Native create is local client construction so location can warm.
    // Web start() is sync; the bundle still loads in the background.
    // ignore() so a create failure is not unhandled if get is never called.
    _created = FingerprintPlatform.instance.create(_config)..ignore();
  }

  /// Identifies the current visitor or device.
  ///
  /// [tags] is a string-keyed map of JSON-compatible values. The same map
  /// is forwarded on every platform, including JSON null.
  /// https://docs.fingerprint.com/docs/tagging-information
  Future<FingerprintResult> get({
    Map<String, Object?>? tags,
    String? linkedId,
    Duration? timeout,
  }) async {
    await _created;
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
