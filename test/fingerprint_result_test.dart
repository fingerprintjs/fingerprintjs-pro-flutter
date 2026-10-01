import 'package:flutter_test/flutter_test.dart';
import 'package:fingerprint_flutter/fingerprint_flutter.dart';

void main() {
  group('FingerprintResult', () {
    test('normalizes empty visitor id and sealed result to null', () {
      final result = FingerprintResult(
        eventId: 'event-1',
        visitorId: '',
        sealedResult: '',
      );

      expect(result.visitorId, isNull);
      expect(result.sealedResult, isNull);
    });

    test('compares by value', () {
      FingerprintResult result({
        String eventId = 'event-1',
        String? visitorId = 'visitor-1',
        int? suspectScore = 1,
        String? sealedResult = 'sealed',
        bool? cacheHit = true,
      }) {
        return FingerprintResult(
          eventId: eventId,
          visitorId: visitorId,
          suspectScore: suspectScore,
          sealedResult: sealedResult,
          cacheHit: cacheHit,
        );
      }

      expect(result(), result());
      expect(result().hashCode, result().hashCode);
      expect(result(), isNot(result(eventId: 'other')));
      expect(result(), isNot(result(visitorId: 'other')));
      expect(result(), isNot(result(suspectScore: 2)));
      expect(result(), isNot(result(sealedResult: 'other')));
      expect(result(), isNot(result(cacheHit: false)));
    });

    test('compares a normalized result equal to its normalized form', () {
      expect(
        FingerprintResult(
          eventId: 'event-1',
          visitorId: null,
          sealedResult: '',
        ),
        FingerprintResult(eventId: 'event-1', visitorId: ''),
      );
    });
  });
}
