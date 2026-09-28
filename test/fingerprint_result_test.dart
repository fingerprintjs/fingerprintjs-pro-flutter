import 'package:flutter_test/flutter_test.dart';
import 'package:fpjs_pro_plugin/result.dart';

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
      final result = FingerprintResult(
        eventId: 'event-1',
        visitorId: 'visitor-1',
        suspectScore: 1,
      );
      final same = FingerprintResult(
        eventId: 'event-1',
        visitorId: 'visitor-1',
        suspectScore: 1,
      );
      final different = FingerprintResult(
        eventId: 'event-1',
        visitorId: 'visitor-1',
        suspectScore: 2,
      );

      expect(result, same);
      expect(result.hashCode, same.hashCode);
      expect(result, isNot(different));
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
