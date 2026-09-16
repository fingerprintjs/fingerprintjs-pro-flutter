import 'dart:js_interop';

// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:fpjs_pro_plugin/error.dart';
import 'package:fpjs_pro_plugin/fingerprint_platform_interface.dart';
import 'package:fpjs_pro_plugin/fpjs_pro_plugin.dart';
import 'package:fpjs_pro_plugin/region.dart';
import 'package:fpjs_pro_plugin/result.dart';
import 'package:fpjs_pro_plugin/web_error.dart';
import 'package:fpjs_pro_plugin/web_result.dart';

import 'js_agent_interop.dart';

/// An implementation of [FingerprintPlatform] that talks to the JS agent
class FingerprintWeb extends FingerprintPlatform {
  Future<FingerprintJSAgent>? _agent;
  var _isExtendedResult = false;

  static void registerWith(Registrar registrar) {
    FingerprintPlatform.instance = FingerprintWeb();
  }

  @override
  Future<void> init(FingerprintConfig config) async {
    final options = FingerprintJSOptions(
      apiKey: config.apiKey,
      integrationInfo:
          _toJSStringArray(['fingerprint-pro-flutter/$pluginVersion/web']),
    );
    if (config.region != null) {
      options.region = config.region!.stringValue;
    }
    if (config.endpoint != null) {
      options.endpoint =
          _toJSStringArray([config.endpoint!, ...?config.endpointFallbacks]);
    }
    if (config.scriptUrlPattern != null) {
      options.scriptUrlPattern = _toJSStringArray(
          [config.scriptUrlPattern!, ...?config.scriptUrlPatternFallbacks]);
    }
    try {
      _agent = FingerprintJS.load(options).toDart;
      _isExtendedResult = config.extendedResponseFormat;
    } catch (e) {
      throw _wrapJsAgentError(e);
    }
  }

  @override
  Future<String?> getVisitorId(
      {Map<String, dynamic>? tags, String? linkedId, int? timeoutMs}) async {
    try {
      final result = await _get(tags, linkedId, timeoutMs, false);
      return result.visitorId;
    } catch (e) {
      throw _wrapJsAgentError(e);
    }
  }

  @override
  Future<FingerprintJSProResponse> getVisitorData(
      {Map<String, dynamic>? tags, String? linkedId, int? timeoutMs}) async {
    try {
      final result = await _get(tags, linkedId, timeoutMs, _isExtendedResult);
      return _isExtendedResult
          ? FingerprintJSProExtendedResponseWeb.fromJsObject(
              result as IdentificationExtendedResult)
          : FingerprintJSProResponseWeb.fromJsObject(result);
    } catch (e) {
      throw _wrapJsAgentError(e);
    }
  }

  Future<IdentificationResult> _get(Map<String, dynamic>? tags,
      String? linkedId, int? timeoutMs, bool extendedResult) async {
    final agent = await _agent!;
    return agent
        .get(FingerprintJSGetOptions(
            linkedId: linkedId,
            tag: tags?.jsify() as JSObject?,
            timeout: timeoutMs,
            extendedResult: extendedResult))
        .toDart;
  }
}

JSArray<JSString> _toJSStringArray(List<String> values) =>
    values.map((value) => value.toJS).toList().toJS;

FingerprintProError _wrapJsAgentError(Object error) {
  // `isA` cannot narrow an extension type without a JS class behind it.
  // ignore: invalid_runtime_check_with_js_interop_types
  if (error is WebException) {
    return unwrapWebError(error);
  }
  return UnknownError(error.toString());
}
