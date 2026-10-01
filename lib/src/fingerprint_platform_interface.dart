// Platform interface that the native and web implementations share.
import 'package:flutter/foundation.dart';
import 'package:fingerprint_flutter/src/options.dart';
import 'package:fingerprint_flutter/src/region.dart';
import 'package:fingerprint_flutter/src/fingerprint_native.dart';
import 'package:fingerprint_flutter/src/fingerprint_result.dart';

/// Configuration passed to every platform [create] and [get].
class FingerprintConfig {
  final String apiKey;
  final Region? region;

  /// Null or non-empty, without empty strings. [Fingerprint] filters them so
  /// platform code can use the list as is.
  final List<String>? endpoints;
  final AndroidOptions? android;
  final IosOptions? ios;
  final WebOptions? web;

  const FingerprintConfig({
    required this.apiKey,
    this.region,
    this.endpoints,
    this.android,
    this.ios,
    this.web,
  });

  // Value equality because the config is the key for cached web agents. Equal
  // configs share one agent. Native code keys its clients on
  // FingerprintNativeConfig instead.
  @override
  bool operator ==(Object other) =>
      other is FingerprintConfig &&
      other.apiKey == apiKey &&
      other.region == region &&
      listEquals(other.endpoints, endpoints) &&
      other.android == android &&
      other.ios == ios &&
      other.web == web;

  @override
  int get hashCode => Object.hash(
    apiKey,
    region,
    Object.hashAll(endpoints ?? const []),
    android,
    ios,
    web,
  );
}

/// The interface each platform implementation of this plugin implements.
///
/// A plain abstract class: only this package implements it, so the
/// plugin_platform_interface token check has nothing to guard.
/// https://pub.dev/packages/plugin_platform_interface
abstract class FingerprintPlatform {
  /// The implementation used by [Fingerprint], [FingerprintNative] by
  /// default. Web registration replaces it.
  static FingerprintPlatform instance = FingerprintNative();

  /// Builds the native or web client for [config]. Warm-up only: [Fingerprint]
  /// ignores the returned future, and [get] reports the same failures as
  /// [FingerprintError].
  Future<void> create(FingerprintConfig config);

  /// Identifies using [config]. Creates the client if [create] never ran.
  Future<FingerprintResult> get(
    FingerprintConfig config, {
    Map<String, Object?>? tags,
    String? linkedId,
    Duration? timeout,
  });
}
