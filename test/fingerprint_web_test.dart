@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpjs_pro_plugin/error.dart';
import 'package:fpjs_pro_plugin/options.dart';
import 'package:fpjs_pro_plugin/region.dart';
import 'package:fpjs_pro_plugin/src/fingerprint_platform_interface.dart';
import 'package:fpjs_pro_plugin/src/fingerprint_web.dart';
import 'package:fpjs_pro_plugin/src/js_agent_interop.dart';

void main() {
  late FakeAgent fake;
  late FingerprintWeb platform;

  FingerprintConfig config({WebOptions? web}) {
    return FingerprintConfig(
      apiKey: 'key-1',
      pluginVersion: '9.9.9',
      region: Region.eu,
      endpoints: const ['https://primary.example', 'https://fallback.example'],
      web: web,
    );
  }

  setUp(() {
    fake = FakeAgent();
    platform = FingerprintWeb(start: fake.start);
  });

  group('start', () {
    test('forwards start options including cache', () async {
      await platform.create(
        config(
          web: const WebOptions(
            storageKeyPrefix: 'fp_',
            urlHashing: WebUrlHashing(path: true, query: true, fragment: false),
            cache: WebCache(
              storage: WebCacheStorage.sessionStorage,
              duration: WebCacheDuration.optimizeCost,
              keyPrefix: 'cache_',
            ),
          ),
        ),
      );

      expect(fake.startOptions['apiKey'], 'key-1');
      expect(fake.startOptions['integrationInfo'], [
        'fingerprint-pro-flutter/9.9.9/web',
      ]);
      expect(fake.startOptions['region'], 'eu');
      expect(fake.startOptions['endpoints'], [
        'https://primary.example',
        'https://fallback.example',
      ]);
      expect(fake.startOptions['storageKeyPrefix'], 'fp_');
      expect(fake.startOptions['urlHashing'], {
        'path': true,
        'query': true,
        'fragment': false,
      });
      expect(fake.startOptions['cache'], {
        'storage': 'sessionStorage',
        'duration': 'optimize-cost',
        'cachePrefix': 'cache_',
      });
    });

    test('sends the aggressive cache duration', () async {
      await platform.create(
        config(
          web: const WebOptions(
            cache: WebCache(
              storage: WebCacheStorage.localStorage,
              duration: WebCacheDuration.aggressive,
            ),
          ),
        ),
      );

      expect(fake.startOptions['cache'], {
        'storage': 'localStorage',
        'duration': 'aggressive',
      });
    });

    test('sends a custom cache duration in seconds', () async {
      await platform.create(
        config(
          web: WebOptions(
            cache: WebCache(
              storage: WebCacheStorage.localStorage,
              duration: WebCacheDuration.custom(const Duration(hours: 2)),
            ),
          ),
        ),
      );

      expect(fake.startOptions['cache'], {
        'storage': 'localStorage',
        'duration': 7200,
      });
    });

    test('two configs keep independent agents', () async {
      final first = config();
      final second = FingerprintConfig(apiKey: 'key-2', pluginVersion: '9.9.9');
      await platform.create(first);
      await platform.create(second);
      await platform.get(first);
      await platform.get(second);

      expect(fake.startCount, 2);
      expect(fake.startApiKeys, ['key-1', 'key-2']);
    });
  });

  group('get', () {
    test('forwards tags, linkedId, and timeout', () async {
      await platform.get(
        config(),
        tags: {'campaign': null, 'sessionId': 1},
        linkedId: 'link-1',
        timeout: const Duration(milliseconds: 500),
      );

      expect(fake.getOptions['tags'], {'campaign': null, 'sessionId': 1});
      expect(fake.getOptions['linkedId'], 'link-1');
      expect(fake.getOptions['timeout'], 500);
    });

    test('maps cacheHit and a missing Zero Trust visitor id', () async {
      fake.nextResult = {
        'event_id': 'evt-1',
        'suspect_score': 12,
        'cache_hit': true,
      };
      final result = await platform.get(config());

      expect(result.eventId, 'evt-1');
      expect(result.visitorId, isNull);
      expect(result.suspectScore, 12);
      expect(result.sealedResult, isNull);
      expect(result.cacheHit, isTrue);
    });

    test('maps a sealed result from BinaryOutput', () async {
      fake.nextResult = {
        'event_id': 'evt-1',
        'visitor_id': 'vid-1',
        'sealed_result': fake.binaryOutput('c2VhbGVk'),
      };
      final result = await platform.get(config());

      expect(result.visitorId, 'vid-1');
      expect(result.sealedResult, 'c2VhbGVk');
    });

    test('maps a JS error code and event id', () async {
      fake.nextError = {
        'code': 'client_timeout',
        'message': 'timed out',
        'event_id': 'evt-err',
      };
      await expectLater(
        platform.get(config()),
        throwsA(
          isA<FingerprintError>()
              .having((error) => error.code, 'code', 'client_timeout')
              .having((error) => error.message, 'message', 'timed out')
              .having((error) => error.eventId, 'eventId', 'evt-err'),
        ),
      );
    });

    test('collapses web network codes into network_error', () async {
      for (final code in ['network_connection', 'network_abort']) {
        fake.nextError = {
          'code': code,
          'message': 'Network failed',
          'event_id': 'evt-err',
        };
        await expectLater(
          platform.get(config()),
          throwsA(
            isA<FingerprintError>().having(
              (error) => error.code,
              'code',
              FingerprintError.networkError,
            ),
          ),
        );
      }
    });

    test('get before create still starts the agent', () async {
      final result = await platform.get(config());
      expect(fake.startCount, 1);
      expect(result.eventId, 'default-event');
    });
  });
}

class FakeAgent {
  var startCount = 0;
  final startApiKeys = <String>[];
  Map<Object?, Object?> startOptions = {};
  Map<Object?, Object?> getOptions = {};
  Map<String, Object?> nextResult = {
    'event_id': 'default-event',
    'visitor_id': 'default-visitor',
  };
  Map<String, Object?>? nextError;

  FingerprintJSAgent start(JSObject options) {
    startCount += 1;
    startOptions = (options.dartify() as Map).cast<Object?, Object?>();
    startApiKeys.add(startOptions['apiKey'] as String);
    final agent = JSObject();
    agent['get'] = _get.toJS;
    return FingerprintJSAgent(agent);
  }

  JSPromise<JSObject> _get([JSObject? options]) {
    getOptions = options == null
        ? {}
        : (options.dartify() as Map).cast<Object?, Object?>();
    final error = nextError;
    if (error != null) {
      final jsError = JSObject();
      jsError['code'] = (error['code'] as String).toJS;
      jsError['message'] = (error['message'] as String).toJS;
      jsError['event_id'] = (error['event_id'] as String).toJS;
      throw jsError;
    }
    return Future<JSObject>.value(nextResult.jsify() as JSObject).toJS;
  }

  JSObject binaryOutput(String base64) {
    final output = JSObject();
    output['base64'] = (() => base64.toJS).toJS;
    return output;
  }
}
