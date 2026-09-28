import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fingerprint_flutter/fingerprint_flutter.dart';
import 'package:fingerprint_flutter/src/fingerprint_native.dart';
import 'package:fingerprint_flutter/src/fingerprint_platform_interface.dart';
import 'package:fingerprint_flutter/src/pigeon/fingerprint_api.g.dart';
import 'package:fingerprint_flutter/src/plugin_version.dart';

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
      expect(fakeHostApi.createdConfig?.region, NativeRegion.eu);
      expect(fakeHostApi.createdConfig?.endpoint, 'https://primary.example');
      expect(fakeHostApi.createdConfig?.endpointFallbacks, [
        'https://fallback.example',
      ]);
      expect(fakeHostApi.createdConfig?.pluginVersion, pluginVersion);
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
      expect(fakeHostApi.lastConfig?.region, NativeRegion.eu);
      expect(fakeHostApi.lastConfig?.endpoint, 'https://primary.example');
      expect(fakeHostApi.lastConfig?.endpointFallbacks, [
        'https://fallback.example',
      ]);
      expect(fakeHostApi.lastConfig?.pluginVersion, pluginVersion);
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

    test('defaults region to US and leaves endpoints unset', () async {
      await platform.create(config());

      expect(fakeHostApi.createdConfig?.region, NativeRegion.us);
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

    // The platform is a shared singleton. A failed create must not make later
    // gets fail, because native get creates the client if it is missing.
    test('create failure does not block a later get', () async {
      fakeHostApi.nextCreateError = PlatformException(
        code: 'unknown_error',
        message: 'create failed',
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

    test('maps a non-platform error to unknown_error', () async {
      fakeHostApi.nextCreateError = StateError('binding not initialized');
      await expectLater(
        platform.create(config()),
        throwsA(
          isA<FingerprintError>()
              .having((error) => error.code, 'code', 'unknown_error')
              .having(
                (error) => error.message,
                'message',
                contains('binding not initialized'),
              ),
        ),
      );
    });

    test('maps a Pigeon channel error to unknown_error', () async {
      fakeHostApi.nextError = PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
      await expectLater(
        platform.get(config()),
        throwsA(
          isA<FingerprintError>()
              .having((error) => error.code, 'code', 'unknown_error')
              .having(
                (error) => error.message,
                'message',
                contains('Unable to establish connection'),
              ),
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

  Object? nextError;
  Object? nextCreateError;

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
