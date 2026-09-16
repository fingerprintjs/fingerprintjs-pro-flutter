import 'package:flutter_test/flutter_test.dart';
import 'package:fpjs_pro_plugin/src/tags.dart';

/// A value with no JSON form, standing in for any Dart object a caller
/// might pass by mistake.
class _NotJson {
  const _NotJson();
}

void main() {
  group('tagsForNative', () {
    test('passes a root map through', () {
      expect(tagsForNative({'userAction': 'login', 'attempt': 2}),
          {'userAction': 'login', 'attempt': 2});
    });

    test('keeps an empty map empty rather than wrapping it', () {
      expect(tagsForNative(<String, Object?>{}), <String, Object?>{});
    });

    test('wraps a scalar, which the native SDKs cannot take on its own', () {
      expect(tagsForNative('login'), {'tag': 'login'});
      expect(tagsForNative(42), {'tag': 42});
      expect(tagsForNative(1.5), {'tag': 1.5});
      expect(tagsForNative(true), {'tag': true});
    });

    test('wraps a root list', () {
      expect(tagsForNative(['a', 'b']), {
        'tag': ['a', 'b']
      });
    });

    test('returns null for null, meaning no tags', () {
      expect(tagsForNative(null), isNull);
    });

    test('accepts a map that is not statically typed as string-keyed', () {
      final Object tags = <dynamic, dynamic>{'userAction': 'login'};
      expect(tagsForNative(tags), {'userAction': 'login'});
    });
  });

  group('tagsForWeb', () {
    test('forwards a root map unwrapped', () {
      expect(tagsForWeb({'userAction': 'login'}), {'userAction': 'login'});
    });

    test('forwards a scalar unwrapped, unlike native', () {
      expect(tagsForWeb('login'), 'login');
      expect(tagsForWeb(42), 42);
    });

    test('forwards a root list unwrapped', () {
      expect(tagsForWeb(['a', 'b']), ['a', 'b']);
    });

    test('returns null for null, meaning no tags', () {
      expect(tagsForWeb(null), isNull);
    });
  });

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
                  {'nested': true}
                ],
                'map': {
                  'deep': {
                    'deeper': ['x']
                  }
                },
              }),
          returnsNormally);
    });

    test('accepts an empty list and an empty map', () {
      expect(() => validateTags(<Object?>[]), returnsNormally);
      expect(() => validateTags(<String, Object?>{}), returnsNormally);
    });

    test('rejects a value with no JSON form', () {
      expect(() => validateTags(const _NotJson()),
          throwsA(isA<ArgumentError>().having((error) => error.message,
              'message', contains('JSON-compatible'))));
    });

    test('rejects a non-string map key', () {
      expect(
          () => validateTags({1: 'a'}),
          throwsA(isA<ArgumentError>().having(
              (error) => error.message, 'message', contains('must be strings'))));
    });

    test('rejects a non-finite number, which has no JSON literal', () {
      expect(() => validateTags(double.nan), throwsA(isA<ArgumentError>()));
      expect(() => validateTags(double.infinity), throwsA(isA<ArgumentError>()));
      expect(() => validateTags(double.negativeInfinity),
          throwsA(isA<ArgumentError>()));
    });

    test('names the path to a rejected value inside a list', () {
      expect(
          () => validateTags({
                'items': [1, const _NotJson()]
              }),
          throwsA(isA<ArgumentError>().having(
              (error) => error.name, 'name', "tags['items'][1]")));
    });

    test('names the path to a rejected value inside a nested map', () {
      expect(
          () => validateTags({
                'outer': {'inner': const _NotJson()}
              }),
          throwsA(isA<ArgumentError>().having(
              (error) => error.name, 'name', "tags['outer']['inner']")));
    });

    test('rejects a non-string key nested in a list', () {
      expect(
          () => validateTags([
                {2: 'a'}
              ]),
          throwsA(isA<ArgumentError>()
              .having((error) => error.name, 'name', 'tags[0]')));
    });

    test('accepts null, meaning no tags', () {
      expect(() => validateTags(null), returnsNormally);
    });

    test('rejects a list that contains itself', () {
      final cyclic = <Object?>['a'];
      cyclic.add(cyclic);

      expect(
          () => validateTags(cyclic),
          throwsA(isA<ArgumentError>().having((error) => error.message,
              'message', contains('cannot contain themselves'))));
    });

    test('rejects a map that contains itself', () {
      final cyclic = <String, Object?>{};
      cyclic['self'] = cyclic;

      expect(() => validateTags(cyclic), throwsA(isA<ArgumentError>()));
    });

    test('rejects a cycle that closes further down', () {
      final outer = <String, Object?>{};
      outer['items'] = [
        {'back': outer}
      ];

      expect(
          () => validateTags(outer),
          throwsA(isA<ArgumentError>().having((error) => error.name, 'name',
              "tags['items'][0]['back']")));
    });

    test('accepts the same collection twice when it is not a cycle', () {
      // Shared structure is fine: it serializes to two copies, not a loop.
      final shared = {'nested': true};

      expect(() => validateTags({'left': shared, 'right': shared}),
          returnsNormally);
      expect(() => validateTags([shared, shared]), returnsNormally);
    });
  });

  group('the shaping functions validate', () {
    test('tagsForNative rejects a bad value before wrapping it', () {
      expect(() => tagsForNative(const _NotJson()),
          throwsA(isA<ArgumentError>()));
      expect(
          () => tagsForNative({
                'bad': [const _NotJson()]
              }),
          throwsA(isA<ArgumentError>()));
    });

    test('tagsForWeb rejects a bad value before forwarding it', () {
      expect(() => tagsForWeb(const _NotJson()), throwsA(isA<ArgumentError>()));
      expect(() => tagsForWeb({1: 'a'}), throwsA(isA<ArgumentError>()));
    });
  });
}
