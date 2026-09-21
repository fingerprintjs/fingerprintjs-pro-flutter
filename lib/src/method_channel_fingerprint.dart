import 'package:flutter/services.dart';
import 'package:fpjs_pro_plugin/error.dart';
import 'package:fpjs_pro_plugin/region.dart';
import 'package:fpjs_pro_plugin/result.dart';
import 'package:fpjs_pro_plugin/src/fingerprint_platform_interface.dart';
import 'package:fpjs_pro_plugin/src/fingerprint_result.dart';
import 'package:fpjs_pro_plugin/src/pigeon/fingerprint_api.g.dart';
import 'package:fpjs_pro_plugin/src/tags.dart';

/// Android and iOS [FingerprintPlatform] using generated [FingerprintHostApi].
class MethodChannelFingerprint extends FingerprintPlatform {
  MethodChannelFingerprint({FingerprintHostApi? hostApi})
      : _hostApi = hostApi ?? FingerprintHostApi();

  final FingerprintHostApi _hostApi;
  FingerprintConfig? _config;

  @override
  Future<void> init(FingerprintConfig config) async {
    try {
      await _hostApi.create(_toNativeConfig(config));
    } on PlatformException catch (exception) {
      throw unwrapError(exception);
    }
    _config = config;
  }

  @override
  Future<String?> getVisitorId({
    Map<String, dynamic>? tags,
    String? linkedId,
    int? timeoutMs,
  }) async {
    final result = await _getNative(tags: tags, linkedId: linkedId, timeoutMs: timeoutMs);
    return FingerprintResult(
      eventId: result.eventId,
      visitorId: result.visitorId,
      suspectScore: result.suspectScore,
      sealedResult: result.sealedResult,
    ).visitorId;
  }

  @override
  Future<FingerprintJSProResponse> getVisitorData({
    Map<String, dynamic>? tags,
    String? linkedId,
    int? timeoutMs,
  }) async {
    final result = await _getNative(tags: tags, linkedId: linkedId, timeoutMs: timeoutMs);
    final normalized = FingerprintResult(
      eventId: result.eventId,
      visitorId: result.visitorId,
      suspectScore: result.suspectScore,
      sealedResult: result.sealedResult,
    );
    return FingerprintJSProResponse(
      normalized.eventId,
      normalized.visitorId ?? '',
      ConfidenceScore(normalized.suspectScore ?? 0),
      normalized.sealedResult,
    );
  }

  Future<FingerprintNativeResult> _getNative({
    Map<String, dynamic>? tags,
    String? linkedId,
    int? timeoutMs,
  }) async {
    final config = _config;
    if (config == null) {
      throw Exception(
        'You need to initialize the FPJS Client first by calling the "initFpjs" method',
      );
    }
    validateTags(tags);
    try {
      return await _hostApi.get(
        _toNativeConfig(config),
        tags,
        linkedId,
        timeoutMs,
      );
    } on PlatformException catch (exception) {
      throw unwrapError(exception);
    }
  }

  FingerprintNativeConfig _toNativeConfig(FingerprintConfig config) {
    final endpoints = config.endpoint != null
        ? [
            config.endpoint!,
            ...?config.endpointFallbacks,
          ]
        : null;
    return FingerprintNativeConfig(
      apiKey: config.apiKey,
      region: config.region?.stringValue,
      endpoints: endpoints,
      pluginVersion: config.pluginVersion,
      allowUseOfLocationData: config.allowUseOfLocationData ?? false,
      locationTimeoutMillis: config.locationTimeoutMillisAndroid,
    );
  }
}
