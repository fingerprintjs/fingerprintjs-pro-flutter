import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpjs_pro_plugin/fpjs_pro_plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel(FpjsProPlugin.channelName);
  const testApiKey = 'test_api_key';
  const testVisitorId = 'test_visitor_id';
  const requestId = 'test_request_id';
  const linkedId = 'test_linked_id';
  const confidence = 0.09;
  const extendedResultAsJson = {'visitorId': testVisitorId};
  final extendedResultAsJsonString = jsonEncode(extendedResultAsJson);
  const getVisitorDataResponse = {
    "requestId": "test_request_id",
    "visitorId": "test_visitor_id",
    "confidenceScore": {"score": 0.09},
    "sealedResult": ''
  };

  const sealedResult = 'test_sealed_result';

  const getVisitorDataResponseWithSealedResult = {
    "requestId": "test_request_id",
    "visitorId": "test_visitor_id",
    "confidenceScore": {"score": 0.09},
    "sealedResult": sealedResult
  };

  TestWidgetsFlutterBinding.ensureInitialized();

  // Passing the future, not a closure, asserts the error arrives through it
  // instead of being thrown synchronously.
  group('Should throw if called before initialization', () {
    test('getVisitorId', () async {
      await expectLater(FpjsProPlugin.getVisitorId(), throwsException);
    });

    test('getVisitorData', () async {
      await expectLater(FpjsProPlugin.getVisitorData(), throwsException);
    });
  });

  group('getVisitorId', () {
    MethodCall? capturedCall;

    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'getVisitorId') {
          capturedCall = methodCall;
          return testVisitorId;
        }
        return null;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('forwards arguments and returns the visitor id', () async {
      const tags = {'sessionId': 1};

      await FpjsProPlugin.initFpjs(testApiKey);
      final result = await FpjsProPlugin.getVisitorId(
          tags: tags, linkedId: linkedId, timeoutMs: 1000);

      expect(result, testVisitorId);
      expect(capturedCall?.arguments, {
        'linkedId': linkedId,
        'tags': tags,
        'timeoutMs': 1000,
      });
    });
  });

  group('getVisitorData', () {
    MethodCall? capturedCall;

    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'getVisitorData') {
          capturedCall = methodCall;
          return [requestId, confidence, extendedResultAsJsonString, null];
        }
        return null;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('forwards arguments and decodes the visitor data', () async {
      const tags = {'sessionId': 1};

      await FpjsProPlugin.initFpjs(testApiKey);
      final result = await FpjsProPlugin.getVisitorData(
          tags: tags, linkedId: linkedId, timeoutMs: 1000);

      expect(result.toJson(), getVisitorDataResponse);
      expect(capturedCall?.arguments, {
        'linkedId': linkedId,
        'tags': tags,
        'timeoutMs': 1000,
      });
    });
  });

  group('getVisitorDataSealed', () {
    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'getVisitorData') {
          return [
            requestId,
            confidence,
            extendedResultAsJsonString,
            sealedResult
          ];
        }
        return null;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('should return data with sealed result', () async {
      await FpjsProPlugin.initFpjs(testApiKey);
      final result = await FpjsProPlugin.getVisitorData();
      expect(result.toJson(), getVisitorDataResponseWithSealedResult);
    });
  });
}
