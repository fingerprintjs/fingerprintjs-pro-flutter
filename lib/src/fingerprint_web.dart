import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:fpjs_pro_plugin/options.dart';
import 'package:fpjs_pro_plugin/region.dart';
import 'package:fpjs_pro_plugin/src/fingerprint_error.dart';
import 'package:fpjs_pro_plugin/src/fingerprint_platform_interface.dart';
import 'package:fpjs_pro_plugin/src/fingerprint_result.dart';
import 'package:fpjs_pro_plugin/src/js_agent_interop.dart';
import 'package:fpjs_pro_plugin/src/tags.dart';

/// Web [FingerprintPlatform] using `@fingerprint/agent` v4.
class FingerprintWeb extends FingerprintPlatform {
  FingerprintWeb({FingerprintJSAgent Function(JSObject options)? start})
    : _start = start ?? ((options) => FingerprintJS.start(options));

  final FingerprintJSAgent Function(JSObject options) _start;
  final _agents = <FingerprintConfig, FingerprintJSAgent>{};

  static void registerWith(Registrar registrar) {
    FingerprintPlatform.instance = FingerprintWeb();
  }

  @override
  Future<void> create(FingerprintConfig config) async {
    _agentFor(config);
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
      final agent = _agentFor(config);
      final options = _toGetOptions(
        tags: tags,
        linkedId: linkedId,
        timeout: timeout,
      );
      // `get(null)` is not `get()`. JS default params only apply to undefined.
      // https://docs.fingerprint.com/reference/js-agent-get-function
      final result =
          await (options == null ? agent.get() : agent.get(options)).toDart;
      return _toResult(result);
    } catch (error) {
      if (error is FingerprintError) {
        rethrow;
      }
      throw _wrapJsError(error);
    }
  }

  FingerprintJSAgent _agentFor(FingerprintConfig config) {
    final existing = _agents[config];
    if (existing != null) {
      return existing;
    }
    try {
      final agent = _start(_toStartOptions(config));
      _agents[config] = agent;
      return agent;
    } catch (error) {
      throw _wrapJsError(error);
    }
  }
}

JSObject _toStartOptions(FingerprintConfig config) {
  final options = <String, Object>{
    'apiKey': config.apiKey,
    'integrationInfo': ['fingerprint-pro-flutter/${config.pluginVersion}/web'],
    if (config.region != null) 'region': config.region!.stringValue,
    if (config.endpoints != null) 'endpoints': config.endpoints!,
  };
  final web = config.web;
  if (web?.storageKeyPrefix != null) {
    options['storageKeyPrefix'] = web!.storageKeyPrefix!;
  }
  final hashing = web?.urlHashing;
  if (hashing != null) {
    options['urlHashing'] = {
      if (hashing.path != null) 'path': hashing.path!,
      if (hashing.query != null) 'query': hashing.query!,
      if (hashing.fragment != null) 'fragment': hashing.fragment!,
    };
  }
  final cache = web?.cache;
  if (cache != null) {
    options['cache'] = {
      'storage': cache.storage.name,
      'duration': _cacheDuration(cache.duration),
      if (cache.keyPrefix != null) 'cachePrefix': cache.keyPrefix!,
    };
  }
  return options.jsify() as JSObject;
}

JSObject? _toGetOptions({
  Map<String, Object?>? tags,
  String? linkedId,
  Duration? timeout,
}) {
  if (tags == null && linkedId == null && timeout == null) {
    return null;
  }
  return {
        'tags': ?tags,
        'linkedId': ?linkedId,
        'timeout': ?timeout?.inMilliseconds,
      }.jsify()
      as JSObject;
}

Object _cacheDuration(WebCacheDuration duration) {
  if (duration == WebCacheDuration.optimizeCost) {
    return 'optimize-cost';
  }
  if (duration == WebCacheDuration.aggressive) {
    return 'aggressive';
  }
  return duration.seconds!;
}

FingerprintResult _toResult(JSObject js) {
  final result = JSGetResult(js);
  return FingerprintResult(
    eventId: result.eventId,
    visitorId: result.visitorId,
    suspectScore: result.suspectScore,
    sealedResult: _sealedResult(result.sealedResult),
    cacheHit: result.cacheHit?.toDart,
  );
}

String? _sealedResult(JSAny? value) {
  if (value == null || value.isUndefinedOrNull) {
    return null;
  }
  if (value.isA<JSString>()) {
    return (value as JSString).toDart;
  }
  return JSBinaryOutput(value as JSObject).base64();
}

FingerprintError _wrapJsError(Object error) {
  // JS errors have no Dart class. `isA` cannot narrow them.
  // ignore: invalid_runtime_check_with_js_interop_types
  if (error is JSObject) {
    final code = error.getProperty('code'.toJS);
    if (code.isA<JSString>()) {
      final message = error.getProperty('message'.toJS);
      final eventId = error.getProperty('event_id'.toJS);
      // The agent splits network failures. Native uses one code.
      var errorCode = (code as JSString).toDart;
      if (errorCode == 'network_connection' || errorCode == 'network_abort') {
        errorCode = FingerprintError.networkError;
      }
      return FingerprintError(
        code: errorCode,
        message: message.isA<JSString>() ? (message as JSString).toDart : null,
        eventId: eventId.isA<JSString>() ? (eventId as JSString).toDart : null,
      );
    }
  }
  return FingerprintError(
    code: FingerprintError.unknownError,
    message: error.toString(),
  );
}
