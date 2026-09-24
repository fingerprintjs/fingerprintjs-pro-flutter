import 'package:flutter/foundation.dart';
import 'package:fingerprint_flutter/options.dart';
import 'package:fingerprint_flutter/region.dart';
import 'package:fingerprint_flutter/src/fingerprint_native.dart';
import 'package:fingerprint_flutter/src/fingerprint_result.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Configuration passed to every platform [create] and [get].
class FingerprintConfig {
  final String apiKey;
  final String pluginVersion;
  final Region? region;
  final List<String>? endpoints;
  final AndroidOptions? android;
  final IosOptions? ios;
  final WebOptions? web;

  const FingerprintConfig({
    required this.apiKey,
    required this.pluginVersion,
    this.region,
    this.endpoints,
    this.android,
    this.ios,
    this.web,
  });

  // Value equality so two configs with the same fields compare equal.
  @override
  bool operator ==(Object other) =>
      other is FingerprintConfig &&
      other.apiKey == apiKey &&
      other.pluginVersion == pluginVersion &&
      other.region == region &&
      listEquals(other.endpoints, endpoints) &&
      other.android == android &&
      other.ios == ios &&
      other.web == web;

  @override
  int get hashCode => Object.hash(
    apiKey,
    pluginVersion,
    region,
    Object.hashAll(endpoints ?? const []),
    android,
    ios,
    web,
  );
}

/// The interface each platform implementation of this plugin implements.
abstract class FingerprintPlatform extends PlatformInterface {
  FingerprintPlatform() : super(token: _token);

  static final Object _token = Object();

  static FingerprintPlatform _instance = FingerprintNative();

  /// The implementation used by [Fingerprint], [FingerprintNative] by default.
  static FingerprintPlatform get instance => _instance;

  static set instance(FingerprintPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Builds the native or web client for [config].
  Future<void> create(FingerprintConfig config);

  /// Identifies using [config]. Creates the client if [create] never ran.
  Future<FingerprintResult> get(
    FingerprintConfig config, {
    Map<String, Object?>? tags,
    String? linkedId,
    Duration? timeout,
  });
}
