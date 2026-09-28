import 'package:flutter_test/flutter_test.dart';
import 'package:fpjs_pro_plugin/options.dart';

void main() {
  test('rejects a zero cache duration', () {
    expect(() => WebCacheDuration.custom(Duration.zero), throwsArgumentError);
  });

  test('accepts a custom cache duration in seconds', () {
    expect(WebCacheDuration.custom(const Duration(hours: 10)).seconds, 36000);
  });

  test('optimizeCost and aggressive stay distinct', () {
    expect(WebCacheDuration.optimizeCost, isNot(WebCacheDuration.aggressive));
    expect(
      WebCacheDuration.optimizeCost,
      isNot(WebCacheDuration.custom(const Duration(hours: 1))),
    );
  });

  test('rejects a cache duration that is not a whole number of seconds', () {
    expect(
      () => WebCacheDuration.custom(const Duration(milliseconds: 1500)),
      throwsArgumentError,
    );
    expect(
      () => WebCacheDuration.custom(const Duration(microseconds: 1)),
      throwsArgumentError,
    );
  });
}
