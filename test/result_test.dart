import 'package:flutter_test/flutter_test.dart';
import 'package:fpjs_pro_plugin/result.dart';

void main() {
  const requestId = '1655373953086.DDlfmP';
  const confidence = 0.995;

  group('FingerprintJSProResponse', () {
    Map<String, String> jsonMock = {};
    Map<String, Object?> extendedJsonMock = {};

    setUp(() {
      jsonMock = {
        "visitorId": 'AcxioeQKffpXF8iGQK3P',
      };

      extendedJsonMock = {
        "requestId": requestId,
        "confidenceScore": {"score": confidence}
      };
      extendedJsonMock.addAll(jsonMock);
    });

    test('Check success scenario with full data', () {
      final responseInstance =
          FingerprintJSProResponse.fromJson(jsonMock, requestId, confidence);
      expect(responseInstance.toJson(), extendedJsonMock);
    });

    test('Check failed scenario with silly data', () {
      jsonMock.remove("visitorId");
      expect(
          () => FingerprintJSProResponse.fromJson(
              jsonMock, requestId, confidence),
          throwsA(isA<TypeError>()));
    });
  });

  group('FingerprintJSProExtendedResponse', () {
    Map<String, Object> jsonMock = {};
    Map<String, Object?> extendedJsonMock = {};

    setUp(() {
      jsonMock = {
        "visitorId": 'AcxioeQKffpXF8iGQK3P',
        "visitorFound": true,
        "ip": '8.8.8.8',
        "ipLocation": {
          "accuracyRadius": 1000,
          "latitude": 50.0805,
          "longitude": 14.467,
          "postalCode": '130 00',
          "timezone": 'Europe/Prague',
          "city": {"name": 'Prague'},
          "country": {"code": 'CZ', "name": 'Czechia'},
          "continent": {"code": 'EU', "name": 'Europe'},
          "subdivisions": [
            {"isoCode": '10', "name": 'Hlavni mesto Praha'}
          ]
        },
        "os": 'iOS',
        "osVersion": '13',
        "device": 'iPhone 13',
        "firstSeenAt": {
          "global": '2022-02-04T11:31:20Z',
          "subscription": '2022-02-04T11:31:20Z'
        },
        "lastSeenAt": {
          "global": '2022-06-16T10:03:00.912Z',
          "subscription": '2022-06-16T10:03:00.912Z'
        }
      };

      extendedJsonMock = {
        "requestId": requestId,
        "confidenceScore": {"score": confidence},
        "ipAddress": jsonMock["ip"],
        "osName": jsonMock["os"]
      };
      extendedJsonMock.addAll(jsonMock);
      extendedJsonMock.remove('ip');
      extendedJsonMock.remove('os');
    });

    test('Check success scenario with full data', () {
      final responseInstance = FingerprintJSProExtendedResponse.fromJson(
          jsonMock, requestId, confidence);
      expect(responseInstance.toJson(), extendedJsonMock);
    });

    test(
        'Check success scenario with nulled fileds of `lastSeenAt` and `firstSeenAt`',
        () {
      const seenAt = {'global': null, 'subscription': null};

      jsonMock["firstSeenAt"] = seenAt;
      jsonMock["lastSeenAt"] = seenAt;

      extendedJsonMock["firstSeenAt"] = seenAt;
      extendedJsonMock["lastSeenAt"] = seenAt;

      final responseInstance = FingerprintJSProExtendedResponse.fromJson(
          jsonMock, requestId, confidence);
      expect(responseInstance.toJson(), extendedJsonMock);
    });

    test('Check failed scenario with missed `visitorId`', () {
      jsonMock.remove("visitorId");
      expect(
          () => FingerprintJSProExtendedResponse.fromJson(
              jsonMock, requestId, confidence),
          throwsA(isA<TypeError>()));
    });

    test('Check failed scenario with missed `firstSeenAt`', () {
      jsonMock.remove("firstSeenAt");
      expect(
          () => FingerprintJSProExtendedResponse.fromJson(
              jsonMock, requestId, confidence),
          throwsA(isA<TypeError>()));
    });

    test('Check serialization and deserialization', () {
      final instance = FingerprintJSProExtendedResponse.fromJson(
          jsonMock, requestId, confidence);
      final serializedInstance = Map<String, dynamic>.from(instance.toJson());
      final deSerializedInstance = FingerprintJSProExtendedResponse.fromJson(
          serializedInstance, requestId, confidence);
      expect(deSerializedInstance.toJson(), extendedJsonMock);
    });

    test('Check `fromJson()` work for web data', () {
      jsonMock['ipAddress'] = '8.8.8.8';
      jsonMock['osName'] = 'iOS';

      jsonMock.remove('ip');
      jsonMock.remove('os');

      final responseInstance = FingerprintJSProExtendedResponse.fromJson(
          jsonMock, requestId, confidence);
      expect(responseInstance.toJson(), extendedJsonMock);
    });

    test('Check success scenario with empty fields for ipLocation', () {
      jsonMock['ipLocation'] = {};
      extendedJsonMock['ipLocation'] = {};
      final responseInstance = FingerprintJSProExtendedResponse.fromJson(
          jsonMock, requestId, confidence);
      expect(responseInstance.toJson(), extendedJsonMock);
    });

    test('Check empty ipLocation for a new customers', () {
      jsonMock.remove('ipLocation');
      extendedJsonMock['ipLocation'] = null;
      final responseInstance = FingerprintJSProExtendedResponse.fromJson(
          jsonMock, requestId, confidence);
      expect(responseInstance.toJson(), extendedJsonMock);
    });
  });
}
