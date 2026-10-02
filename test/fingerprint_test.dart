import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:fingerprint_flutter/fingerprint_flutter.dart';
import 'package:fingerprint_flutter/src/fingerprint_platform_interface.dart';

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
      ios: const IosOptions(allowUseOfLocationData: true),
      web: const WebOptions(storageKeyPrefix: 'fp_'),
    );
    await client.get();

    expect(platform.created, hasLength(1));
    expect(platform.created.single.apiKey, 'key-1');
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
    expect(platform.created.single.ios?.allowUseOfLocationData, isTrue);
    expect(platform.created.single.web?.storageKeyPrefix, 'fp_');
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

  test('rejects invalid tags without identifying', () {
    final client = Fingerprint(apiKey: 'key-1');

    expect(() => client.get(tags: {'value': Object()}), throwsArgumentError);
    expect(platform.gets, isEmpty);
  });

  test('rejects a timeout under 1 ms without identifying', () {
    final client = Fingerprint(apiKey: 'key-1');

    for (final timeout in const [
      Duration(seconds: -1),
      Duration.zero,
      Duration(microseconds: 500),
    ]) {
      expect(() => client.get(timeout: timeout), throwsArgumentError);
    }
    expect(platform.gets, isEmpty);
  });

  test('accepts a 1 ms timeout', () async {
    final client = Fingerprint(apiKey: 'key-1');

    await client.get(timeout: const Duration(milliseconds: 1));

    expect(platform.gets.single.timeout, const Duration(milliseconds: 1));
  });

  test('rejects an Android location timeout under 1 ms without starting', () {
    for (final timeout in const [
      Duration(seconds: -1),
      Duration.zero,
      Duration(microseconds: 500),
    ]) {
      expect(
        () => Fingerprint(
          apiKey: 'key-1',
          android: AndroidOptions(locationTimeout: timeout),
        ),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.name,
            'name',
            'android.locationTimeout',
          ),
        ),
      );
    }
    expect(platform.created, isEmpty);
  });

  test('accepts a 1 ms Android location timeout', () async {
    final client = Fingerprint(
      apiKey: 'key-1',
      android: const AndroidOptions(locationTimeout: Duration(milliseconds: 1)),
    );
    await client.get();

    expect(
      platform.created.single.android?.locationTimeout,
      const Duration(milliseconds: 1),
    );
  });

  // Constructor create is only a warm-up. Its failure must not become an
  // uncaught async error or break get.
  test('a failed constructor start does not break get', () async {
    platform.createError = FingerprintError(
      code: FingerprintError.unknownError,
    );
    final client = Fingerprint(apiKey: 'key-1');

    final result = await client.get();

    expect(result.visitorId, 'key-1');
  });

  test(
    'treats an empty endpoints list as null, uses the regional default',
    () async {
      final client = Fingerprint(apiKey: 'key-1', endpoints: const []);
      await client.get();

      expect(client.endpoints, isNull);
      expect(platform.created.single.endpoints, isNull);
    },
  );

  test(
    'drops empty endpoint strings before splitting primary and fallbacks',
    () async {
      final client = Fingerprint(
        apiKey: 'key-1',
        endpoints: const ['', 'https://proxy.example', ''],
      );
      await client.get();

      expect(client.endpoints, ['https://proxy.example']);
      expect(platform.created.single.endpoints, ['https://proxy.example']);
    },
  );

  test(
    'treats a list of empty endpoint strings as null, uses the regional default',
    () async {
      final client = Fingerprint(apiKey: 'key-1', endpoints: const ['', '']);
      await client.get();

      expect(client.endpoints, isNull);
      expect(platform.created.single.endpoints, isNull);
    },
  );

  test('rejects an endpoint without http(s) scheme or host', () {
    for (final url in const [
      'example.com/path',
      'ftp://example.com',
      'https://',
    ]) {
      expect(
        () => Fingerprint(
          apiKey: 'key-1',
          endpoints: ['https://proxy.example', url],
        ),
        throwsA(
          isA<ArgumentError>()
              .having((error) => error.name, 'name', 'endpoints')
              .having((error) => error.invalidValue, 'invalidValue', url),
        ),
      );
    }
    expect(platform.created, isEmpty);
  });

  test('accepts http(s) endpoints with port, path, and query', () async {
    final client = Fingerprint(
      apiKey: 'key-1',
      endpoints: const [
        'https://example.com/path?region=eu',
        'http://localhost:8080',
      ],
    );
    await client.get();

    expect(platform.created.single.endpoints, [
      'https://example.com/path?region=eu',
      'http://localhost:8080',
    ]);
  });

  group('get tags validation', () {
    Future<FingerprintResult> get(Map<String, Object?>? tags) =>
        Fingerprint(apiKey: 'key-1').get(tags: tags);

    Matcher throwsWithMessage(String part) => throwsA(
      isA<ArgumentError>().having(
        (error) => error.message,
        'message',
        contains(part),
      ),
    );

    Matcher throwsAtPath(String path) => throwsA(
      isA<ArgumentError>().having((error) => error.name, 'name', path),
    );

    test('accepts every JSON type, nested to depth', () async {
      const tags = {
        'string': 'a',
        'int': 1,
        'double': 1.5,
        'bool': true,
        'null': null,
        'list': [
          1,
          'a',
          null,
          {'nested': true},
        ],
        'map': {
          'deep': {
            'deeper': ['x'],
          },
        },
      };
      await get(tags);

      expect(platform.gets.single.tags, tags);
    });

    test('accepts null, an empty map, and a nested empty list', () async {
      await get(null);
      await get(<String, Object?>{});
      await get({'items': <Object?>[]});

      expect(platform.gets, hasLength(3));
    });

    test('rejects a typed list, which Pigeon would drop on iOS', () {
      expect(
        () => get({
          'bytes': Uint8List.fromList(const [1, 2]),
        }),
        throwsWithMessage('JSON-compatible'),
      );
    });

    test('rejects a non-string nested map key', () {
      expect(
        () => get({
          'nested': <Object?, Object?>{1: 'a'},
        }),
        throwsWithMessage('must be strings'),
      );
    });

    test('rejects a non-finite number, which has no JSON literal', () {
      for (final value in [
        double.nan,
        double.infinity,
        double.negativeInfinity,
      ]) {
        expect(() => get({'value': value}), throwsArgumentError);
      }
    });

    test('names the path to a rejected value inside a list', () {
      expect(
        () => get({
          'items': [1, Object()],
        }),
        throwsAtPath("tags['items'][1]"),
      );
    });

    test('names the path to a rejected value inside a nested map', () {
      expect(
        () => get({
          'outer': {'inner': Object()},
        }),
        throwsAtPath("tags['outer']['inner']"),
      );
    });

    test('names the path to a non-string key nested in a list', () {
      expect(
        () => get({
          'items': [
            {2: 'a'},
          ],
        }),
        throwsAtPath("tags['items'][0]"),
      );
    });
  });
}

class RecordingPlatform extends FingerprintPlatform {
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
