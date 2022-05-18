import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpjs_pro_plugin/fpjs_pro_plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel(FpjsProPlugin.channelName);
  const testApiKey = 'test_api_key';
  const testVisitorId = 'test_visitor_id';

  TestWidgetsFlutterBinding.ensureInitialized();

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

  group('getVisitorId', () {
    test('should throw if called before initialization', () async {
      expect(() => FpjsProPlugin.getVisitorId(), throwsException);
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
  });
}
