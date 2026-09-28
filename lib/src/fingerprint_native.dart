// Android and iOS platform code. Dart config and errors go through Pigeon.
// https://pub.dev/packages/pigeon
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fpjs_pro_plugin/region.dart';
import 'package:fpjs_pro_plugin/src/fingerprint_error.dart';
import 'package:fpjs_pro_plugin/src/fingerprint_platform_interface.dart';
import 'package:fpjs_pro_plugin/src/fingerprint_result.dart';
import 'package:fpjs_pro_plugin/src/pigeon/fingerprint_api.g.dart';

/// Android and iOS [FingerprintPlatform] using generated [FingerprintHostApi].
class FingerprintNative extends FingerprintPlatform {
  FingerprintNative({FingerprintHostApi? hostApi})
    : _hostApi = hostApi ?? FingerprintHostApi();

  final FingerprintHostApi _hostApi;

  @override
  Future<void> create(FingerprintConfig config) async {
    try {
      await _hostApi.create(_toNativeConfig(config));
    } catch (error) {
      throw _toFingerprintError(error);
    }
  }

  @override
  Future<FingerprintResult> get(
    FingerprintConfig config, {
    Map<String, Object?>? tags,
    String? linkedId,
    Duration? timeout,
  }) async {
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
    } catch (error) {
      throw _toFingerprintError(error);
    }
  }

  FingerprintNativeConfig _toNativeConfig(FingerprintConfig config) {
    final endpoints = config.endpoints;
    return FingerprintNativeConfig(
      apiKey: config.apiKey,
      region: config.region?.stringValue,
      endpoint: endpoints?.first,
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

// Pigeon's own codes when the call never reached native SDK code.
const _pigeonCodes = {'channel-error', 'null-error'};

/// - Native code already sends snake_case codes. [PlatformException.details]
///   is the event id when the client reported one.
/// - Pigeon codes and other errors (e.g. a missing Flutter binding) become
///   [FingerprintError.unknownError] with the original text as message, so
///   `get` only throws [FingerprintError] with a documented code.
FingerprintError _toFingerprintError(Object error) {
  if (error is! PlatformException) {
    return FingerprintError(
      code: FingerprintError.unknownError,
      message: error.toString(),
    );
  }
  if (_pigeonCodes.contains(error.code)) {
    return FingerprintError(
      code: FingerprintError.unknownError,
      message: '${error.code}: ${error.message}',
    );
  }
  final details = error.details;
  return FingerprintError(
    code: error.code,
    message: error.message,
    eventId: details is String ? details : null,
  );
}
