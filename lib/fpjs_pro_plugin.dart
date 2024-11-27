import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:fpjs_pro_plugin/error.dart';
import 'package:fpjs_pro_plugin/region.dart';
import 'package:fpjs_pro_plugin/result.dart';

// Update it on each release
const pluginVersion = '3.2.0';

/// A plugin that accesses native FingerprintJS Pro libraries to get a device identifier
class FpjsProPlugin {
  static const channelName = 'fpjs_pro_plugin';

  /// A channel used for communication with the native libraries
  static const MethodChannel _channel = MethodChannel(channelName);

  static var _isInitialized = false;
  static var _isExtendedResult = false;

  /// Initializes the native FingerprintJS Pro client
  /// Throws a [PlatformException] if [apiKey] is missing
  static Future<void> initFpjs(String apiKey,
      {String? endpoint,
      List<String>? endpointFallbacks,
      String? scriptUrlPattern,
      List<String>? scriptUrlPatternFallbacks,
      Region? region,
      bool extendedResponseFormat = false}) async {
    await _channel.invokeMethod('init', {
      'apiToken': apiKey,
      'endpoint': endpoint,
      'endpointFallbacks': endpointFallbacks,
      'scriptUrlPattern': scriptUrlPattern,
      'scriptUrlPatternFallbacks': scriptUrlPatternFallbacks,
      'region': region?.stringValue,
      'extendedResponseFormat': extendedResponseFormat,
      'pluginVersion': pluginVersion,
    });
    _isExtendedResult = extendedResponseFormat;
    _isInitialized = true;
  }

  /// Returns the visitorId generated by the native Fingerprint Pro client
  /// Support [tags](https://dev.fingerprint.com/docs/quick-start-guide#tagging-your-requests)
  /// Support [linkedId](https://dev.fingerprint.com/docs/quick-start-guide#tagging-your-requests)
  /// Throws a [FingerprintProError] if identification request fails for any reason
  static Future<String?> getVisitorId(
      {Map<String, dynamic>? tags, String? linkedId}) async {
    if (!_isInitialized) {
      throw Exception(
          'You need to initialize the FPJS Client first by calling the "initFpjs" method');
    }

    try {
      final String? visitorId = await _channel
          .invokeMethod('getVisitorId', {'linkedId': linkedId, 'tags': tags});
      return visitorId;
    } on PlatformException catch (exception) {
      throw unwrapError(exception);
    }
  }

  /// Returns the visitor data generated by the native Fingerprint Pro client
  /// Support [tags](https://dev.fingerprint.com/docs/quick-start-guide#tagging-your-requests)
  /// Support [linkedId](https://dev.fingerprint.com/docs/quick-start-guide#tagging-your-requests)
  /// Throws a [FingerprintProError] if identification request fails for any reason
  static Future<T> getVisitorData<T extends FingerprintJSProResponse>(
      {Map<String, dynamic>? tags, String? linkedId}) async {
    if (!_isInitialized) {
      throw Exception(
          'You need to initialize the FPJS Client first by calling the "initFpjs" method');
    }

    try {
      final visitorDataTuple = await _channel
          .invokeMethod('getVisitorData', {'linkedId': linkedId, 'tags': tags});

      final String requestId = visitorDataTuple[0];
      final num confidence = visitorDataTuple[1];
      final String sealedResult = visitorDataTuple[3] ?? '';

      Map<String, dynamic> visitorDataJson;
      if (kIsWeb) {
        visitorDataJson = Map<String, dynamic>.from(visitorDataTuple[2]);
      } else {
        final String visitorDataJsonString = visitorDataTuple[2];
        visitorDataJson = jsonDecode(visitorDataJsonString);
      }

      final visitorData = _isExtendedResult
          ? FingerprintJSProExtendedResponse.fromJson(
              visitorDataJson, requestId, confidence, sealedResult)
          : FingerprintJSProResponse.fromJson(
              visitorDataJson, requestId, confidence, sealedResult);

      return visitorData as T;
    } on PlatformException catch (exception) {
      throw unwrapError(exception);
    }
  }
}
