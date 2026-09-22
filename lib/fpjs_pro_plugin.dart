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
/// start. Every get carries the full config, so two clients stay independent.
/// https://docs.fingerprint.com/docs/ios-sdk
/// https://docs.fingerprint.com/docs/android-quickstart
class Fingerprint {
  /// Public API key for this client.
  final String apiKey;

  /// Workspace region. The agent picks one from the key when omitted.
  final Region? region;

  /// Identification endpoints, first to last. Null uses the regional default.
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
  }) : endpoints = endpoints == null
           ? null
           : List<String>.unmodifiable(endpoints) {
    if (this.endpoints != null && this.endpoints!.isEmpty) {
      throw ArgumentError.value(
        this.endpoints,
        'endpoints',
        'Use null for the default endpoints, not an empty list',
      );
    }
    _config = FingerprintConfig(
      apiKey: apiKey,
      pluginVersion: pluginVersion,
      region: region,
      endpoints: this.endpoints,
      android: android,
      ios: ios,
      web: web,
    );
    _created = FingerprintPlatform.instance.create(_config);
  }

  /// Completes when the platform client has been created.
  ///
  /// [get] waits for this. Await it to surface a start failure without
  /// identifying.
  Future<void> get ready => _created;

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
