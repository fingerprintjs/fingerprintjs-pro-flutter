import 'package:flutter_test/flutter_test.dart';
import 'package:fpjs_pro_plugin/src/fingerprint_error.dart';

void main() {
  group('FingerprintError', () {
    test('keeps the code, message and event id it was given', () {
      final error = FingerprintError(
        code: FingerprintError.tooManyRequests,
        message: 'Too many requests',
        eventId: 'event-1',
      );

      expect(error.code, 'too_many_requests');
      expect(error.message, 'Too many requests');
      expect(error.eventId, 'event-1');
    });

    test('keeps a code added by a newer identification client', () {
      final error = FingerprintError(code: 'some_future_code');

      expect(error.code, 'some_future_code');
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

    test('keeps an event id without inferring policy from its code', () {
      final error = FingerprintError(
        code: FingerprintError.networkError,
        eventId: 'event-1',
      );

      expect(error.eventId, 'event-1');
    });

    test('is an Exception', () {
      final error = FingerprintError(code: FingerprintError.failed);

      expect(error, isA<Exception>());
      expect(() => throw error, throwsA(same(error)));
    });

    test('includes its available fields in toString', () {
      final error = FingerprintError(
        code: FingerprintError.tooManyRequests,
        message: 'Too many requests',
        eventId: 'event-1',
      );

      expect(
        error.toString(),
        'FingerprintError(too_many_requests, Too many requests, '
        'eventId: event-1)',
      );
    });

    test('leaves missing fields out of toString', () {
      expect(
        FingerprintError(code: FingerprintError.clientTimeout).toString(),
        'FingerprintError(client_timeout)',
      );
    });

  });
}
