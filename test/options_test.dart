import 'package:flutter_test/flutter_test.dart';
import 'package:fpjs_pro_plugin/options.dart';

void main() {
  test('rejects a cache duration above 12 hours', () {
    expect(
      () => WebCacheDuration.custom(const Duration(hours: 12, seconds: 1)),
      throwsArgumentError,
    );
  });

  test('rejects a zero cache duration', () {
    expect(() => WebCacheDuration.custom(Duration.zero), throwsArgumentError);
  });

  test('accepts a 12 hour cache duration', () {
    expect(WebCacheDuration.custom(const Duration(hours: 12)).seconds, 43200);
  });
}
