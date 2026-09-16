import 'package:flutter_test/flutter_test.dart';
import 'package:fpjs_pro_plugin/fingerprint_platform_interface.dart';
import 'package:fpjs_pro_plugin/fpjs_pro_plugin.dart';
import 'package:fpjs_pro_plugin/method_channel_fingerprint.dart';
import 'package:fpjs_pro_plugin/region.dart';
import 'package:fpjs_pro_plugin/result.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class FakeFingerprint extends FingerprintPlatform
    with MockPlatformInterfaceMixin {
  final response = FingerprintJSProResponse(
      'test_request_id', 'test_visitor_id', ConfidenceScore(1), null);

  FingerprintConfig? config;
  Map<String, dynamic>? tags;
  String? linkedId;
  int? timeoutMs;

  @override
  Future<void> init(FingerprintConfig config) async => this.config = config;

  @override
  Future<String?> getVisitorId(
      {Map<String, dynamic>? tags, String? linkedId, int? timeoutMs}) async {
    _record(tags, linkedId, timeoutMs);
    return response.visitorId;
  }

  @override
  Future<FingerprintJSProResponse> getVisitorData(
      {Map<String, dynamic>? tags, String? linkedId, int? timeoutMs}) async {
    _record(tags, linkedId, timeoutMs);
    return response;
  }

  void _record(Map<String, dynamic>? tags, String? linkedId, int? timeoutMs) {
    this.tags = tags;
    this.linkedId = linkedId;
    this.timeoutMs = timeoutMs;
  }
}

void main() {
  late FakeFingerprint fake;

  setUp(() {
    fake = FakeFingerprint();
    FingerprintPlatform.instance = fake;
  });

  test('uses the method channel implementation by default', () {
    FingerprintPlatform.instance = MethodChannelFingerprint();
    expect(FingerprintPlatform.instance, isA<MethodChannelFingerprint>());
  });

  test('initFpjs passes the configuration to the platform', () async {
    await FpjsProPlugin.initFpjs('test_api_key',
        endpoint: 'https://example.com', region: Region.eu);

    expect(fake.config?.apiKey, 'test_api_key');
    expect(fake.config?.endpoint, 'https://example.com');
    expect(fake.config?.region, Region.eu);
    expect(fake.config?.extendedResponseFormat, false);
  });

  test('getVisitorId passes the arguments to the platform', () async {
    await FpjsProPlugin.initFpjs('test_api_key');
    final visitorId = await FpjsProPlugin.getVisitorId(
        tags: {'sessionId': 1}, linkedId: 'test_linked_id', timeoutMs: 1000);

    expect(visitorId, fake.response.visitorId);
    expect(fake.tags, {'sessionId': 1});
    expect(fake.linkedId, 'test_linked_id');
    expect(fake.timeoutMs, 1000);
  });

  test('getVisitorData returns the result from the platform', () async {
    await FpjsProPlugin.initFpjs('test_api_key');
    final result =
        await FpjsProPlugin.getVisitorData(linkedId: 'test_linked_id');

    expect(result, fake.response);
    expect(fake.linkedId, 'test_linked_id');
  });
}
