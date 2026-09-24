import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:fingerprint_flutter/src/tags.dart';

/// A value with no JSON form.
class _NotJson {
  const _NotJson();
}

void main() {
  group('validateTags', () {
    test('accepts every JSON type, nested to depth', () {
      expect(
        () => validateTags({
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
        }),
        returnsNormally,
      );
    });

    test('accepts an empty root map and a nested empty list', () {
      expect(() => validateTags(<String, Object?>{}), returnsNormally);
      expect(() => validateTags({'items': <Object?>[]}), returnsNormally);
    });

    test('rejects a typed list, which Pigeon would drop on iOS', () {
      expect(
        () => validateTags({
          'bytes': Uint8List.fromList(const [1, 2]),
        }),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            contains('JSON-compatible'),
          ),
        ),
      );
    });

    test('rejects a nested value with no JSON form', () {
      expect(
        () => validateTags({'value': const _NotJson()}),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            contains('JSON-compatible'),
          ),
        ),
      );
    });

    test('rejects a non-string nested map key', () {
      expect(
        () => validateTags({
          'nested': <Object?, Object?>{1: 'a'},
        }),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            contains('must be strings'),
          ),
        ),
      );
    });

    test('rejects a non-finite number, which has no JSON literal', () {
      expect(
        () => validateTags({'value': double.nan}),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => validateTags({'value': double.infinity}),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => validateTags({'value': double.negativeInfinity}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('names the path to a rejected value inside a list', () {
      expect(
        () => validateTags({
          'items': [1, const _NotJson()],
        }),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.name,
            'name',
            "tags['items'][1]",
          ),
        ),
      );
    });

    test('names the path to a rejected value inside a nested map', () {
      expect(
        () => validateTags({
          'outer': {'inner': const _NotJson()},
        }),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.name,
            'name',
            "tags['outer']['inner']",
          ),
        ),
      );
    });

    test('rejects a non-string key nested in a list', () {
      expect(
        () => validateTags({
          'items': [
            {2: 'a'},
          ],
        }),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.name,
            'name',
            "tags['items'][0]",
          ),
        ),
      );
    });

    test('accepts null, meaning no tags', () {
      expect(() => validateTags(null), returnsNormally);
    });
  });
}
