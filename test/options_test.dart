import 'package:flutter_test/flutter_test.dart';
import 'package:fingerprint_flutter/fingerprint_flutter.dart';

void main() {
  test('rejects a zero cache duration', () {
    expect(() => WebCacheDuration.custom(Duration.zero), throwsArgumentError);
  });

  test('accepts a custom cache duration in seconds', () {
    expect(
      WebCacheDuration.custom(const Duration(hours: 10)),
      isA<WebCacheCustomDuration>().having((d) => d.seconds, 'seconds', 36000),
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
