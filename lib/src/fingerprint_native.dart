import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fingerprint_flutter/region.dart';
import 'package:fingerprint_flutter/src/fingerprint_platform_interface.dart';
import 'package:fingerprint_flutter/src/fingerprint_result.dart';
import 'package:fingerprint_flutter/src/pigeon/fingerprint_api.g.dart';
import 'package:fingerprint_flutter/src/tags.dart';
import 'package:fingerprint_flutter/src/unwrap_error.dart';

/// Android and iOS [FingerprintPlatform] using generated [FingerprintHostApi].
class FingerprintNative extends FingerprintPlatform {
  FingerprintNative({FingerprintHostApi? hostApi})
    : _hostApi = hostApi ?? FingerprintHostApi();

  final FingerprintHostApi _hostApi;

  @override
  Future<void> create(FingerprintConfig config) async {
    try {
      await _hostApi.create(_toNativeConfig(config));
    } on PlatformException catch (exception) {
      throw unwrapError(exception);
    }
  }

  @override
  Future<FingerprintResult> get(
    FingerprintConfig config, {
    Map<String, Object?>? tags,
    String? linkedId,
    Duration? timeout,
  }) async {
    validateTags(tags);
    try {
      final result = await _hostApi.get(
        _toNativeConfig(config),
        tags,
        linkedId,
        timeout?.inMilliseconds,
      );
      return FingerprintResult(
        eventId: result.eventId,
        visitorId: result.visitorId,
        suspectScore: result.suspectScore,
        sealedResult: result.sealedResult,
      );
    } on PlatformException catch (exception) {
      throw unwrapError(exception);
    }
  }

  FingerprintNativeConfig _toNativeConfig(FingerprintConfig config) {
    final endpoints = config.endpoints;
    return FingerprintNativeConfig(
      apiKey: config.apiKey,
      region: config.region?.stringValue,
      endpoint: endpoints == null || endpoints.isEmpty ? null : endpoints.first,
      endpointFallbacks: endpoints != null && endpoints.length > 1
          ? endpoints.sublist(1)
          : null,
      pluginVersion: config.pluginVersion,
      allowUseOfLocationData: _allowLocation(config),
      locationTimeoutMillis: config.android?.locationTimeout?.inMilliseconds,
    );
  }

  bool _allowLocation(FingerprintConfig config) {
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS => config.ios?.allowUseOfLocationData ?? false,
      _ => config.android?.allowUseOfLocationData ?? false,
    };
  }
}
