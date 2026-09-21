import 'package:flutter_test/flutter_test.dart';
import 'package:fpjs_pro_plugin/fpjs_pro_plugin.dart';
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

  group('Should throw if called before initialization', () {
    test('getVisitorId', () async {
      await expectLater(FpjsProPlugin.getVisitorId(), throwsException);
    });

    test('getVisitorData', () async {
      await expectLater(FpjsProPlugin.getVisitorData(), throwsException);
    });
  });

  group('getVisitorId', () {
    test('forwards arguments and returns the visitor id', () async {
      const tags = {'sessionId': 1};
      const linkedId = 'test_linked_id';
      const testVisitorId = 'test_visitor_id';

      fakeHostApi.nextResult = FingerprintNativeResult(
        eventId: 'evt',
        visitorId: testVisitorId,
        suspectScore: 0,
        sealedResult: null,
      );

      await FpjsProPlugin.initFpjs('test_api_key');
      final result = await FpjsProPlugin.getVisitorId(
        tags: tags,
        linkedId: linkedId,
        timeoutMs: 1000,
      );

      expect(result, testVisitorId);
      expect(fakeHostApi.lastTags, tags);
      expect(fakeHostApi.lastLinkedId, linkedId);
      expect(fakeHostApi.lastTimeoutMs, 1000);
      expect(fakeHostApi.lastConfig?.apiKey, 'test_api_key');
    });
  });

  group('getVisitorData', () {
    test('forwards arguments and maps visitor data', () async {
      const tags = {'sessionId': 1};
      const linkedId = 'test_linked_id';
      const requestId = 'test_request_id';
      const testVisitorId = 'test_visitor_id';
      const sealedResult = 'test_sealed_result';

      fakeHostApi.nextResult = FingerprintNativeResult(
        eventId: requestId,
        visitorId: testVisitorId,
        suspectScore: 9,
        sealedResult: sealedResult,
      );

      await FpjsProPlugin.initFpjs('test_api_key');
      final result = await FpjsProPlugin.getVisitorData(
        tags: tags,
        linkedId: linkedId,
        timeoutMs: 1000,
      );

      expect(
        result.toJson(),
        {
          'requestId': requestId,
          'visitorId': testVisitorId,
          'confidenceScore': {'score': 9},
          'sealedResult': sealedResult,
        },
      );
      expect(fakeHostApi.lastTags, tags);
      expect(fakeHostApi.lastLinkedId, linkedId);
      expect(fakeHostApi.lastTimeoutMs, 1000);
    });
  });
}

class FakeFingerprintHostApi extends FingerprintHostApi {
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

  @override
  Future<void> create(FingerprintNativeConfig config) async {}

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
    return nextResult;
  }
}
