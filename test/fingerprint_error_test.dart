import 'package:flutter_test/flutter_test.dart';
import 'package:fingerprint_flutter/error.dart';

void main() {
  group('FingerprintError', () {
    test('keeps a Server API-only code that has no constant', () {
      final error = FingerprintError(code: 'unexpected_error_code');

      expect(error.code, 'unexpected_error_code');
    });

    test('normalizes an empty code to unknown_error', () {
      final error = FingerprintError(code: '');

      expect(error.code, FingerprintError.unknownError);
    });

    test('normalizes empty optional strings to null', () {
      final error = FingerprintError(
        code: FingerprintError.failed,
        message: '',
        eventId: '',
      );

      expect(error.message, isNull);
      expect(error.eventId, isNull);
    });
  });
}
