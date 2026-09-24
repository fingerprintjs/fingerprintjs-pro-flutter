import 'package:flutter_test/flutter_test.dart';
import 'package:fingerprint_flutter/options.dart';

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
