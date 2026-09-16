import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:fpjs_pro_plugin/error.dart';
import 'package:fpjs_pro_plugin/fingerprint_platform_interface.dart';
import 'package:fpjs_pro_plugin/fpjs_pro_plugin.dart';
import 'package:fpjs_pro_plugin/region.dart';
import 'package:fpjs_pro_plugin/result.dart';

/// An implementation of [FingerprintPlatform] that talks to the Android and iOS agents
class MethodChannelFingerprint extends FingerprintPlatform {
  static const channelName = 'fpjs_pro_plugin';

  final MethodChannel _channel = const MethodChannel(channelName);

  var _isExtendedResult = false;

  @override
  Future<void> init(FingerprintConfig config) async {
    await _channel.invokeMethod('init', {
      'apiToken': config.apiKey,
      'endpoint': config.endpoint,
      'endpointFallbacks': config.endpointFallbacks,
      'scriptUrlPattern': config.scriptUrlPattern,
      'scriptUrlPatternFallbacks': config.scriptUrlPatternFallbacks,
      'region': config.region?.stringValue,
      'extendedResponseFormat': config.extendedResponseFormat,
      'pluginVersion': pluginVersion,
      'allowUseOfLocationData': config.allowUseOfLocationData,
      'locationTimeoutMillis': config.locationTimeoutMillisAndroid,
    });
    _isExtendedResult = config.extendedResponseFormat;
  }

  @override
  Future<String?> getVisitorId(
      {Map<String, dynamic>? tags, String? linkedId, int? timeoutMs}) async {
    try {
      return await _channel.invokeMethod<String>('getVisitorId',
          {'linkedId': linkedId, 'tags': tags, 'timeoutMs': timeoutMs});
    } on PlatformException catch (exception) {
      throw unwrapError(exception);
    }
  }

  @override
  Future<FingerprintJSProResponse> getVisitorData(
      {Map<String, dynamic>? tags, String? linkedId, int? timeoutMs}) async {
    try {
      final visitorDataTuple = await _channel.invokeMethod('getVisitorData',
          {'linkedId': linkedId, 'tags': tags, 'timeoutMs': timeoutMs});

      final String requestId = visitorDataTuple[0];
      final num confidence = visitorDataTuple[1];
      final Map<String, dynamic> visitorDataJson =
          jsonDecode(visitorDataTuple[2]);
      final String sealedResult = visitorDataTuple[3] ?? '';

      return _isExtendedResult
          ? FingerprintJSProExtendedResponse.fromJson(
              visitorDataJson, requestId, confidence, sealedResult)
          : FingerprintJSProResponse.fromJson(
              visitorDataJson, requestId, confidence, sealedResult);
    } on PlatformException catch (exception) {
      throw unwrapError(exception);
    }
  }
}
