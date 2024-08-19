import 'dart:async';
import 'dart:js_util';

// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:fpjs_pro_plugin/error.dart';
import 'package:fpjs_pro_plugin/result.dart';
import 'package:fpjs_pro_plugin/web_error.dart';

import 'js_agent_interop.dart';

/// A web implementation of the FpjsProPlugin plugin.
class FpjsProPluginWeb {
  static bool _isExtendedResult = false;
  static bool _isInitialized = false;
  static Future<FingerprintJSAgent>? _fpPromise;

  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
      'fpjs_pro_plugin',
      const StandardMethodCodec(),
      registrar,
    );

    final pluginInstance = FpjsProPluginWeb();
    channel.setMethodCallHandler(pluginInstance.handleMethodCall);
  }

  /// Handles method calls over the MethodChannel of this plugin.
  /// Note: Check the "federated" architecture for a new way of doing this:
  /// https://flutter.dev/go/federated-plugins
  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'init':
        initFpjs(call);
        return;
      case 'getVisitorId':
        return getVisitorId(
            linkedId: call.arguments['linkedId'],
            tags: getTags(call.arguments['tags']));
      case 'getVisitorData':
        return getVisitorData(
            linkedId: call.arguments['linkedId'],
            tags: getTags(call.arguments['tags']));
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details:
              'fpjs_pro_plugin for web doesn\'t implement \'${call.method}\'',
        );
    }
  }

  /// Initializes the native FingerprintJS Pro client
  /// Throws a [FingerprintProError] if initialisation fails
  static Future<void> initFpjs(MethodCall call) async {
    final options = FingerprintJSOptions(
      apiKey: call.arguments['apiToken'],
      integrationInfo: [
        "fingerprint-pro-flutter/${call.arguments['pluginVersion']}/web"
      ],
    );
    if (call.arguments['region'] != null) {
      options.region = call.arguments['region'];
    }
    if (call.arguments['endpoint'] != null) {
      options.endpoint = [
        call.arguments['endpoint'],
        ...(call.arguments['endpointFallbacks'] ?? [])
      ];
    }
    if (call.arguments['scriptUrlPattern'] != null) {
      options.scriptUrlPattern = [
        call.arguments['scriptUrlPattern'],
        ...(call.arguments['scriptUrlPatternFallbacks'] ?? [])
      ];
    }
    try {
      _fpPromise = promiseToFuture(FingerprintJS.load(options));
      _isExtendedResult = call.arguments['extendedResponseFormat'];
      _isInitialized = true;
    } catch (e) {
      if (e is WebException) {
        throw unwrapWebError(e);
      } else {
        throw UnknownError(e.toString());
      }
    }
  }

  /// Returns the visitorId generated by the native Fingerprint Pro client
  /// Support [tags](https://dev.fingerprint.com/docs/quick-start-guide#tagging-your-requests)
  /// Support [linkedId](https://dev.fingerprint.com/docs/quick-start-guide#tagging-your-requests)
  /// Throws a [FingerprintProError] if identification request fails for any reason
  static Future<String?> getVisitorId({Object? tags, String? linkedId}) async {
    if (!_isInitialized) {
      throw Exception(
          'You need to initialize the FPJS Client first by calling the "initFpjs" method');
    }

    try {
      FingerprintJSAgent fp = await (_fpPromise as Future<FingerprintJSAgent>);
      var result = await promiseToFuture(
          fp.get(FingerprintJSGetOptions(linkedId: linkedId, tag: tags)));
      return result.visitorId;
    } catch (e) {
      if (e is WebException) {
        throw unwrapWebError(e);
      } else {
        throw UnknownError(e.toString());
      }
    }
  }

  /// Returns the visitor data generated by the native Fingerprint Pro client
  /// Support [tags](https://dev.fingerprint.com/docs/quick-start-guide#tagging-your-requests)
  /// Support [linkedId](https://dev.fingerprint.com/docs/quick-start-guide#tagging-your-requests)
  /// Throws a [FingerprintProError] if identification request fails for any reason
  static Future<List<Object>> getVisitorData(
      {Object? tags, String? linkedId}) async {
    if (!_isInitialized) {
      throw Exception(
          'You need to initialize the FPJS Client first by calling the "initFpjs" method');
    }
    try {
      FingerprintJSAgent fp = await (_fpPromise as Future<FingerprintJSAgent>);
      final getOptions = FingerprintJSGetOptions(
          linkedId: linkedId, tag: tags, extendedResult: _isExtendedResult);
      final IdentificationResult result =
          await promiseToFuture(fp.get(getOptions));

      FingerprintJSProResponse typedResult;

      if (_isExtendedResult) {
        typedResult = FingerprintJSProExtendedResponse.fromJsObject(
            result as IdentificationExtendedResult);
      } else {
        typedResult = FingerprintJSProResponse.fromJsObject(result);
      }

      final serializedResult = typedResult.toJson();
      return [
        typedResult.requestId,
        typedResult.confidenceScore.score,
        serializedResult
      ];
    } catch (e) {
      if (e is WebException) {
        throw unwrapWebError(e);
      } else {
        throw UnknownError(e.toString());
      }
    }
  }
}

/// Casts [tags](https://dev.fingerprint.com/docs/quick-start-guide#tagging-your-requests) from Dart Object to JavaScript Object
Object? getTags(Object? tags) {
  return tags != null ? jsify(tags) : null;
}
