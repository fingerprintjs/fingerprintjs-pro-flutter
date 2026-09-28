@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter_test/flutter_test.dart';
import 'package:fingerprint_flutter/error.dart';
import 'package:fingerprint_flutter/options.dart';
import 'package:fingerprint_flutter/region.dart';
import 'package:fingerprint_flutter/src/fingerprint_platform_interface.dart';
import 'package:fingerprint_flutter/src/fingerprint_web.dart';
import 'package:fingerprint_flutter/src/js_agent_interop.dart';

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

    test('omits unset start fields', () async {
      await platform.create(
        FingerprintConfig(apiKey: 'key-1', pluginVersion: '9.9.9'),
      );

      expect(fake.startOptions.containsKey('region'), isFalse);
      expect(fake.startOptions.containsKey('endpoints'), isFalse);
      expect(fake.startOptions.containsKey('storageKeyPrefix'), isFalse);
      expect(fake.startOptions.containsKey('urlHashing'), isFalse);
      expect(fake.startOptions.containsKey('cache'), isFalse);
    });

    test('sends the agent cache storage', () async {
      await platform.create(
        config(
          web: const WebOptions(
            cache: WebCache(
              storage: WebCacheStorage.agent,
              duration: WebCacheDuration.optimizeCost,
            ),
          ),
        ),
      );

      expect(fake.startOptions['cache'], {
        'storage': 'agent',
        'duration': 'optimize-cost',
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

    test('same key with different web options starts two agents', () async {
      final first = config(web: const WebOptions(storageKeyPrefix: 'a_'));
      final second = config(web: const WebOptions(storageKeyPrefix: 'b_'));
      expect(first, isNot(second));
      await platform.create(first);
      await platform.create(second);

      expect(fake.startCount, 2);
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

    test(
      'calls get with no options object when all get args are omitted',
      () async {
        await platform.get(config());

        expect(fake.getArgCount, 0);
      },
    );

    test('omits absent get fields instead of sending null', () async {
      await platform.get(config(), linkedId: 'link-1');

      expect(fake.getArgCount, 1);
      expect(fake.getOptions.containsKey('tags'), isFalse);
      expect(fake.getOptions.containsKey('timeout'), isFalse);
      expect(fake.getOptions['linkedId'], 'link-1');
    });

    test('reuses one agent for equal configs', () async {
      final first = config();
      final second = config();
      expect(first, second);

      await platform.get(first);
      await platform.get(second);

      expect(fake.startCount, 1);
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

    test('maps a sealed result from a string', () async {
      fake.nextResult = {
        'event_id': 'evt-1',
        'visitor_id': 'vid-1',
        'sealed_result': 'c2VhbGVk',
      };
      final result = await platform.get(config());

      expect(result.sealedResult, 'c2VhbGVk');
    });

    test('maps a JS error code and event id', () async {
      fake.nextError = jsError(
        'timed out',
        code: 'client_timeout',
        eventId: 'evt-err',
      );
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
        fake.nextError = jsError('Network failed', code: code);
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

    test('maps a JS error without a code to unknown_error', () async {
      fake.nextError = jsError('boom');
      await expectLater(
        platform.get(config()),
        throwsA(
          isA<FingerprintError>()
              .having((error) => error.code, 'code', 'unknown_error')
              .having((error) => error.message, 'message', contains('boom')),
        ),
      );
    });

    test(
      'maps a throw from start and retries start on the next call',
      () async {
        fake.startError = jsError('start failed');
        await expectLater(
          platform.create(config()),
          throwsA(
            isA<FingerprintError>()
                .having((error) => error.code, 'code', 'unknown_error')
                .having(
                  (error) => error.message,
                  'message',
                  contains('start failed'),
                ),
          ),
        );

        fake.startError = null;
        final result = await platform.get(config());
        expect(result.eventId, 'default-event');
      },
    );

    test('get before create still starts the agent', () async {
      final result = await platform.get(config());
      expect(fake.startCount, 1);
      expect(result.eventId, 'default-event');
    });

    test('maps a JS value without a code to unknown_error', () async {
      fake.nextThrow = 'start failed';
      await expectLater(
        platform.get(config()),
        throwsA(
          isA<FingerprintError>().having(
            (error) => error.code,
            'code',
            FingerprintError.unknownError,
          ),
        ),
      );
    });
  });

  test('wraps a start failure as FingerprintError', () async {
    platform = FingerprintWeb(start: (_) => throw 'start failed');
    await expectLater(
      platform.create(config()),
      throwsA(
        isA<FingerprintError>().having(
          (error) => error.code,
          'code',
          FingerprintError.unknownError,
        ),
      ),
    );
  });
}

class FakeAgent {
  var startCount = 0;
  var getArgCount = -1;
  final startApiKeys = <String>[];
  Map<Object?, Object?> startOptions = {};
  Map<Object?, Object?> getOptions = {};
  Map<String, Object?> nextResult = {
    'event_id': 'default-event',
    'visitor_id': 'default-visitor',
  };
  JSObject? nextError;
  Object? nextThrow;
  JSObject? startError;

  FingerprintAgent start(JSObject options) {
    final error = startError;
    if (error != null) {
      throw error;
    }
    startCount += 1;
    startOptions = (options.dartify() as Map).cast<Object?, Object?>();
    startApiKeys.add(startOptions['apiKey'] as String);
    final agent = JSObject();
    // Count JS arguments so get() and get(null) stay distinct.
    // JS default params only apply to undefined.
    // https://docs.fingerprint.com/reference/js-agent-get-function
    globalContext['__fpDartGet'] = _get.toJS;
    globalContext['__fpRecordGetArgCount'] = ((int count) {
      getArgCount = count;
    }).toJS;
    agent['get'] =
        (globalContext.callMethod(
              'eval'.toJS,
              r'''
                (function() {
                  return function() {
                    globalThis.__fpRecordGetArgCount(arguments.length);
                    return globalThis.__fpDartGet.apply(this, arguments);
                  };
                })()
              '''
                  .toJS,
            )
            as JSFunction);
    return FingerprintAgent(agent);
  }

  JSPromise<JSObject> _get([JSObject? options]) {
    getOptions = options == null
        ? {}
        : (options.dartify() as Map).cast<Object?, Object?>();
    final thrown = nextThrow;
    if (thrown != null) {
      throw thrown;
    }
    final error = nextError;
    if (error != null) {
      throw error;
    }
    return Future<JSObject>.value(nextResult.jsify() as JSObject).toJS;
  }

  JSObject binaryOutput(String base64) {
    final output = JSObject();
    output['base64'] = (() => base64.toJS).toJS;
    return output;
  }
}

/// A JS `Error`, like the agent throws. [code] and [eventId] are set only when
/// given.
JSObject jsError(String message, {String? code, String? eventId}) {
  final error = (globalContext['Error'] as JSFunction)
      .callAsConstructor<JSObject>(message.toJS);
  if (code != null) {
    error['code'] = code.toJS;
  }
  if (eventId != null) {
    error['event_id'] = eventId.toJS;
  }
  return error;
}
