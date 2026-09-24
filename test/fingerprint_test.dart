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

  test('constructor creates the platform client', () async {
    final client = Fingerprint(
      apiKey: 'key-1',
      region: Region.eu,
      endpoints: const ['https://primary.example', 'https://fallback.example'],
      android: const AndroidOptions(
        allowUseOfLocationData: true,
        locationTimeout: Duration(seconds: 3),
      ),
    );
    await client.get();

    expect(platform.created, hasLength(1));
    expect(platform.created.single.apiKey, 'key-1');
    expect(platform.created.single.pluginVersion, pluginVersion);
    expect(platform.created.single.region, Region.eu);
    expect(platform.created.single.endpoints, [
      'https://primary.example',
      'https://fallback.example',
    ]);
    expect(platform.created.single.android?.allowUseOfLocationData, isTrue);
    expect(
      platform.created.single.android?.locationTimeout,
      const Duration(seconds: 3),
    );
  });

  test('two clients keep independent configs', () async {
    final first = Fingerprint(apiKey: 'key-a', region: Region.eu);
    final second = Fingerprint(apiKey: 'key-b', region: Region.ap);

    await first.get();
    await second.get(linkedId: 'second');

    expect(platform.gets, hasLength(2));
    expect(platform.gets[0].config.apiKey, 'key-a');
    expect(platform.gets[0].config.region, Region.eu);
    expect(platform.gets[1].config.apiKey, 'key-b');
    expect(platform.gets[1].config.region, Region.ap);
    expect(platform.gets[1].linkedId, 'second');
  });

  test('forwards tags, linkedId, and timeout', () async {
    final client = Fingerprint(apiKey: 'key-1');
    await client.get(
      tags: const {'campaign': null, 'sessionId': 1},
      linkedId: 'link-1',
      timeout: const Duration(milliseconds: 500),
    );

    expect(platform.gets.single.tags, {'campaign': null, 'sessionId': 1});
    expect(platform.gets.single.linkedId, 'link-1');
    expect(platform.gets.single.timeout, const Duration(milliseconds: 500));
  });

  test('get surfaces a create failure without identifying', () async {
    platform.createError = FingerprintError(
      code: FingerprintError.apiKeyInvalid,
    );
    final client = Fingerprint(apiKey: 'key-1');

    await expectLater(
      client.get(),
      throwsA(
        isA<FingerprintError>().having(
          (error) => error.code,
          'code',
          FingerprintError.apiKeyInvalid,
        ),
      ),
    );
    expect(platform.gets, isEmpty);
  });

  test('treats an empty endpoints list as the regional default', () async {
    final client = Fingerprint(apiKey: 'key-1', endpoints: const []);
    await client.get();

    expect(client.endpoints, isNull);
    expect(platform.created.single.endpoints, isNull);
  });
}

class RecordingPlatform extends FingerprintPlatform
    with MockPlatformInterfaceMixin {
  final created = <FingerprintConfig>[];
  final gets = <_GetCall>[];
  FingerprintError? createError;

  @override
  Future<void> create(FingerprintConfig config) async {
    if (createError != null) {
      throw createError!;
    }
    created.add(config);
  }

  @override
  Future<FingerprintResult> get(
    FingerprintConfig config, {
    Map<String, Object?>? tags,
    String? linkedId,
    Duration? timeout,
  }) async {
    gets.add(_GetCall(config, tags, linkedId, timeout));
    return FingerprintResult(eventId: 'event-1', visitorId: config.apiKey);
  }
}

class _GetCall {
  _GetCall(this.config, this.tags, this.linkedId, this.timeout);

  final FingerprintConfig config;
  final Map<String, Object?>? tags;
  final String? linkedId;
  final Duration? timeout;
}
