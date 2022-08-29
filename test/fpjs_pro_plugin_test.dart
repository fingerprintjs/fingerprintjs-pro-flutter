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
  const extendedResultAsJson = {
    'visitorId': testVisitorId
  };
  final extendedResultAsJsonString = jsonEncode(extendedResultAsJson);
  const getVisitorDataResponse = {
    "requestId": "test_request_id",
    "visitorId": "test_visitor_id",
    "confidenceScore": {"score": 0.09},
    "errorMessage": null
  };

  TestWidgetsFlutterBinding.ensureInitialized();

  group('Should throw if called before initialization', () {
    test('getVisitorId', () async {
      expect(() => FpjsProPlugin.getVisitorId(), throwsException);
    });

    test('getVisitorData', () async {
      expect(() => FpjsProPlugin.getVisitorData(), throwsException);
    });
  });

  group('getVisitorId', () {

    setUp(() {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'getVisitorId') {
          return testVisitorId;
        }
      });
    });

    tearDown(() {
      channel.setMockMethodCallHandler(null);
    });

    test('should return visitor id when called without tags', () async {
      await FpjsProPlugin.initFpjs(testApiKey);
      final result = await FpjsProPlugin.getVisitorId();
      expect(result, testVisitorId);
    });

    test('should return visitor id when called with tags', () async {
      await FpjsProPlugin.initFpjs(testApiKey);
      final result = await FpjsProPlugin.getVisitorId(
          tags: {'sessionId': DateTime.now().millisecondsSinceEpoch});
      expect(result, testVisitorId);
    });

    test('should return visitor id when called with linkedId', () async {
      await FpjsProPlugin.initFpjs(testApiKey);
      final result = await FpjsProPlugin.getVisitorId(linkedId: linkedId);
      expect(result, testVisitorId);
    });
  });

  group('getVisitorData', () {
    setUp(() {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'getVisitorData') {
          return [requestId, confidence, extendedResultAsJsonString];
        }
      });
    });

    tearDown(() {
      channel.setMockMethodCallHandler(null);
    });

    test('should return visitor id when called without tags', () async {
      await FpjsProPlugin.initFpjs(testApiKey);
      final result = await FpjsProPlugin.getVisitorData();
      expect(result.toJson(), getVisitorDataResponse);
    });

    test('should return visitor id when called with tags', () async {
      await FpjsProPlugin.initFpjs(testApiKey);
      final result = await FpjsProPlugin.getVisitorData(
          tags: {'sessionId': DateTime.now().millisecondsSinceEpoch});
      expect(result.toJson(), getVisitorDataResponse);
    });

    test('should return visitor id when called with linkedId', () async {
      await FpjsProPlugin.initFpjs(testApiKey);
      final result = await FpjsProPlugin.getVisitorData(linkedId: linkedId);
      expect(result.toJson(), getVisitorDataResponse);
    });
  });
}
