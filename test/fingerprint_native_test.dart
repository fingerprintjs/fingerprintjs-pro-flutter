import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpjs_pro_plugin/error.dart';
import 'package:fpjs_pro_plugin/options.dart';
import 'package:fpjs_pro_plugin/region.dart';
import 'package:fpjs_pro_plugin/src/fingerprint_native.dart';
import 'package:fpjs_pro_plugin/src/fingerprint_platform_interface.dart';
import 'package:fpjs_pro_plugin/src/pigeon/fingerprint_api.g.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFingerprintHostApi fakeHostApi;
  late FingerprintNative platform;

  setUp(() {
    fakeHostApi = FakeFingerprintHostApi();
    platform = FingerprintNative(hostApi: fakeHostApi);
  });

  FingerprintConfig config({
    String apiKey = 'key-1',
    Region? region,
    List<String>? endpoints,
    AndroidOptions? android,
    IosOptions? ios,
  }) {
    return FingerprintConfig(
      apiKey: apiKey,
      pluginVersion: '9.9.9',
      region: region,
      endpoints: endpoints,
      android: android,
      ios: ios,
    );
  }

  group('config and call forwarding', () {
    test('creates the native client during create', () async {
      await platform.create(
        config(
          region: Region.eu,
          endpoints: const [
            'https://primary.example',
            'https://fallback.example',
          ],
          android: const AndroidOptions(
            allowUseOfLocationData: true,
            locationTimeout: Duration(milliseconds: 3000),
          ),
        ),
      );

      expect(fakeHostApi.createdConfig?.apiKey, 'key-1');
      expect(fakeHostApi.createdConfig?.region, 'eu');
      expect(fakeHostApi.createdConfig?.endpoint, 'https://primary.example');
      expect(fakeHostApi.createdConfig?.endpointFallbacks, [
        'https://fallback.example',
      ]);
      expect(fakeHostApi.createdConfig?.pluginVersion, '9.9.9');
      expect(fakeHostApi.createdConfig?.allowUseOfLocationData, isTrue);
      expect(fakeHostApi.createdConfig?.locationTimeoutMillis, 3000);
    });

    test('forwards config and get arguments on every call', () async {
      final request = config(
        region: Region.eu,
        endpoints: const [
          'https://primary.example',
          'https://fallback.example',
        ],
        android: const AndroidOptions(
          allowUseOfLocationData: true,
          locationTimeout: Duration(milliseconds: 3000),
        ),
      );

      await platform.get(
        request,
        tags: const {'sessionId': 1},
        linkedId: 'link-1',
        timeout: const Duration(milliseconds: 500),
      );

      expect(fakeHostApi.lastConfig?.apiKey, 'key-1');
      expect(fakeHostApi.lastConfig?.region, 'eu');
      expect(fakeHostApi.lastConfig?.endpoint, 'https://primary.example');
      expect(fakeHostApi.lastConfig?.endpointFallbacks, [
        'https://fallback.example',
      ]);
      expect(fakeHostApi.lastConfig?.pluginVersion, '9.9.9');
      expect(fakeHostApi.lastConfig?.allowUseOfLocationData, isTrue);
      expect(fakeHostApi.lastConfig?.locationTimeoutMillis, 3000);
      expect(fakeHostApi.lastTags, {'sessionId': 1});
      expect(fakeHostApi.lastLinkedId, 'link-1');
      expect(fakeHostApi.lastTimeoutMs, 500);
    });

    test('forwards JSON null tag values unchanged', () async {
      await platform.get(config(), tags: {'campaign': null, 'sessionId': 1});

      expect(fakeHostApi.lastTags, {'campaign': null, 'sessionId': 1});
    });

    test('uses iOS location on iOS', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      await platform.create(
        config(
          android: const AndroidOptions(allowUseOfLocationData: false),
          ios: const IosOptions(allowUseOfLocationData: true),
        ),
      );

      expect(fakeHostApi.createdConfig?.allowUseOfLocationData, isTrue);
    });

    test('leaves region and endpoints unset when omitted', () async {
      await platform.create(config());

      expect(fakeHostApi.createdConfig?.region, isNull);
      expect(fakeHostApi.createdConfig?.endpoint, isNull);
      expect(fakeHostApi.createdConfig?.endpointFallbacks, isNull);
      expect(fakeHostApi.createdConfig?.locationTimeoutMillis, isNull);
      expect(fakeHostApi.createdConfig?.allowUseOfLocationData, isFalse);
    });

    test('forwards a single endpoint without fallbacks', () async {
      await platform.create(
        config(endpoints: const ['https://primary.example']),
      );

      expect(fakeHostApi.createdConfig?.endpoint, 'https://primary.example');
      expect(fakeHostApi.createdConfig?.endpointFallbacks, isNull);
    });

    test('omits timeout when get does not pass one', () async {
      await platform.get(config());

      expect(fakeHostApi.lastTimeoutMs, isNull);
    });

    test('uses Android location on Android', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      await platform.create(
        config(
          android: const AndroidOptions(allowUseOfLocationData: false),
          ios: const IosOptions(allowUseOfLocationData: true),
        ),
      );

      expect(fakeHostApi.createdConfig?.allowUseOfLocationData, isFalse);
    });

    test('rejects invalid tags before the host is called', () async {
      await expectLater(
        platform.get(
          config(),
          tags: {
            'bytes': Uint8List.fromList(const [1, 2]),
          },
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(fakeHostApi.lastConfig, isNull);
    });

    test('create failure does not block a later get', () async {
      fakeHostApi.nextCreateError = PlatformException(
        code: 'unknown_error',
        message: 'Invalid region: xx',
      );
      await expectLater(
        platform.create(config()),
        throwsA(isA<FingerprintError>()),
      );

      final result = await platform.get(config());
      expect(result.eventId, 'default-event');
    });
  });

  group('result mapping', () {
    test('empty visitorId becomes null', () async {
      fakeHostApi.nextResult = FingerprintNativeResult(
        eventId: 'evt',
        visitorId: '',
        suspectScore: 10,
        sealedResult: null,
      );
      final result = await platform.get(config());
      expect(result.visitorId, isNull);
      expect(result.eventId, 'evt');
      expect(result.suspectScore, 10);
    });

    test('maps eventId, visitorId, suspectScore, sealedResult', () async {
      fakeHostApi.nextResult = FingerprintNativeResult(
        eventId: 'evt-1',
        visitorId: 'vid-1',
        suspectScore: 42,
        sealedResult: 'sealed',
      );
      final result = await platform.get(config());
      expect(result.eventId, 'evt-1');
      expect(result.visitorId, 'vid-1');
      expect(result.suspectScore, 42);
      expect(result.sealedResult, 'sealed');
      expect(result.cacheHit, isNull);
    });
  });

  group('errors', () {
    test('maps PlatformException to FingerprintError with eventId', () async {
      fakeHostApi.nextError = PlatformException(
        code: 'public_api_key_required',
        message: 'API key required',
        details: 'evt-9',
      );
      await expectLater(
        platform.get(config()),
        throwsA(
          isA<FingerprintError>()
              .having((error) => error.code, 'code', 'public_api_key_required')
              .having((error) => error.message, 'message', 'API key required')
              .having((error) => error.eventId, 'eventId', 'evt-9'),
        ),
      );
    });

    test('keeps an unknown code unchanged', () async {
      fakeHostApi.nextError = PlatformException(
        code: 'new_server_code',
        message: 'from a newer native SDK',
      );
      await expectLater(
        platform.get(config()),
        throwsA(
          isA<FingerprintError>().having(
            (error) => error.code,
            'code',
            'new_server_code',
          ),
        ),
      );
    });
  });
}

class FakeFingerprintHostApi extends FingerprintHostApi {
  FingerprintNativeConfig? createdConfig;
  FingerprintNativeConfig? lastConfig;
  Map<String?, Object?>? lastTags;
  String? lastLinkedId;
  int? lastTimeoutMs;

  FingerprintNativeResult nextResult = FingerprintNativeResult(
    eventId: 'default-event',
    visitorId: 'default-visitor',
    suspectScore: 0,
    sealedResult: null,
  );

  PlatformException? nextError;
  PlatformException? nextCreateError;

  @override
  Future<void> create(FingerprintNativeConfig config) async {
    if (nextCreateError != null) {
      throw nextCreateError!;
    }
    createdConfig = config;
  }

  @override
  Future<FingerprintNativeResult> get(
    FingerprintNativeConfig config,
    Map<String?, Object?>? tags,
    String? linkedId,
    int? timeoutMs,
  ) async {
    lastConfig = config;
    lastTags = tags;
    lastLinkedId = linkedId;
    lastTimeoutMs = timeoutMs;
    if (nextError != null) {
      throw nextError!;
    }
    return nextResult;
  }
}
