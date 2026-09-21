import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpjs_pro_plugin/error.dart';
import 'package:fpjs_pro_plugin/fpjs_pro_plugin.dart';
import 'package:fpjs_pro_plugin/region.dart';
import 'package:fpjs_pro_plugin/src/fingerprint_platform_interface.dart';
import 'package:fpjs_pro_plugin/src/method_channel_fingerprint.dart';
import 'package:fpjs_pro_plugin/src/pigeon/fingerprint_api.g.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFingerprintHostApi fakeHostApi;
  late FingerprintPlatform previousPlatform;

  setUp(() {
    fakeHostApi = FakeFingerprintHostApi();
    previousPlatform = FingerprintPlatform.instance;
    FingerprintPlatform.instance = MethodChannelFingerprint(hostApi: fakeHostApi);
  });

  tearDown(() {
    FingerprintPlatform.instance = previousPlatform;
  });

  group('config and call forwarding', () {
    test('forwards stored config and get arguments on every call', () async {
      await FingerprintPlatform.instance.init(FingerprintConfig(
        apiKey: 'key-1',
        pluginVersion: '9.9.9',
        region: Region.eu,
        endpoint: 'https://primary.example',
        endpointFallbacks: ['https://fallback.example'],
        allowUseOfLocationData: true,
        locationTimeoutMillisAndroid: 3000,
      ));

      await FingerprintPlatform.instance.getVisitorId(
        tags: const {'sessionId': 1},
        linkedId: 'link-1',
        timeoutMs: 500,
      );

      expect(fakeHostApi.lastConfig?.apiKey, 'key-1');
      expect(fakeHostApi.lastConfig?.region, 'eu');
      expect(fakeHostApi.lastConfig?.endpoints, [
        'https://primary.example',
        'https://fallback.example',
      ]);
      expect(fakeHostApi.lastConfig?.pluginVersion, '9.9.9');
      expect(fakeHostApi.lastConfig?.allowUseOfLocationData, isTrue);
      expect(fakeHostApi.lastConfig?.locationTimeoutMillis, 3000);
      expect(fakeHostApi.lastTags, {'sessionId': 1});
      expect(fakeHostApi.lastLinkedId, 'link-1');
      expect(fakeHostApi.lastTimeoutMs, 500);
    });
  });

  group('result mapping', () {
    setUp(() async {
      await FingerprintPlatform.instance.init(FingerprintConfig(
        apiKey: 'key',
        pluginVersion: pluginVersion,
      ));
    });

    test('empty visitorId becomes null from getVisitorId', () async {
      fakeHostApi.nextResult = FingerprintNativeResult(
        eventId: 'evt',
        visitorId: '',
        suspectScore: 10,
        sealedResult: null,
      );
      final visitorId = await FingerprintPlatform.instance.getVisitorId();
      expect(visitorId, isNull);
    });

    test('getVisitorData maps eventId, visitorId, suspectScore, sealedResult',
        () async {
      fakeHostApi.nextResult = FingerprintNativeResult(
        eventId: 'evt-1',
        visitorId: 'vid-1',
        suspectScore: 42,
        sealedResult: 'sealed',
      );
      final data = await FingerprintPlatform.instance.getVisitorData();
      expect(data.requestId, 'evt-1');
      expect(data.visitorId, 'vid-1');
      expect(data.confidenceScore.score, 42);
      expect(data.sealedResult, 'sealed');
    });
  });

  group('errors', () {
    setUp(() async {
      await FingerprintPlatform.instance.init(FingerprintConfig(
        apiKey: 'key',
        pluginVersion: pluginVersion,
      ));
    });

    test('maps snake_case PlatformException to FingerprintProError', () async {
      fakeHostApi.nextError = PlatformException(
        code: 'public_api_key_required',
        message: 'API key required',
      );
      await expectLater(
        FingerprintPlatform.instance.getVisitorId(),
        throwsA(isA<ApiKeyRequiredError>()),
      );
    });
  });
}

class FakeFingerprintHostApi extends FingerprintHostApi {
  FingerprintNativeConfig? lastConfig;
  Map<Object?, Object?>? lastTags;
  String? lastLinkedId;
  int? lastTimeoutMs;

  FingerprintNativeResult nextResult = FingerprintNativeResult(
    eventId: 'default-event',
    visitorId: 'default-visitor',
    suspectScore: 0,
    sealedResult: null,
  );

  PlatformException? nextError;

  @override
  Future<FingerprintNativeResult> get(
    FingerprintNativeConfig config,
    Map<Object?, Object?>? tags,
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
