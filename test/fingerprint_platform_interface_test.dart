import 'package:flutter_test/flutter_test.dart';
import 'package:fpjs_pro_plugin/fpjs_pro_plugin.dart';
import 'package:fpjs_pro_plugin/src/fingerprint_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  late RecordingPlatform platform;
  late FingerprintPlatform previous;

  setUp(() {
    platform = RecordingPlatform();
    previous = FingerprintPlatform.instance;
    FingerprintPlatform.instance = platform;
  });

  tearDown(() {
    FingerprintPlatform.instance = previous;
  });

  test('Fingerprint.create passes configuration to the platform', () async {
    final client = Fingerprint(
      apiKey: 'test_api_key',
      endpoints: const ['https://example.com'],
      region: Region.eu,
    );
    await client.get();

    expect(platform.config?.apiKey, 'test_api_key');
    expect(platform.config?.pluginVersion, pluginVersion);
    expect(platform.config?.endpoints, ['https://example.com']);
    expect(platform.config?.region, Region.eu);
  });

  test('Fingerprint.get returns the platform result', () async {
    final client = Fingerprint(apiKey: 'test_api_key');
    final result = await client.get(linkedId: 'test_linked_id');

    expect(result.eventId, 'test_request_id');
    expect(result.visitorId, 'test_visitor_id');
    expect(platform.linkedId, 'test_linked_id');
  });
}

class RecordingPlatform extends FingerprintPlatform
    with MockPlatformInterfaceMixin {
  FingerprintConfig? config;
  String? linkedId;

  @override
  Future<void> create(FingerprintConfig config) async => this.config = config;

  @override
  Future<FingerprintResult> get(
    FingerprintConfig config, {
    Map<String, Object?>? tags,
    String? linkedId,
    Duration? timeout,
  }) async {
    this.linkedId = linkedId;
    return FingerprintResult(
      eventId: 'test_request_id',
      visitorId: 'test_visitor_id',
    );
  }
}
