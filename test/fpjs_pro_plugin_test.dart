import 'package:flutter_test/flutter_test.dart';
import 'package:fpjs_pro_plugin/fpjs_pro_plugin.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Should throw if called before initialization', () {
    test('getVisitorId', () async {
      await expectLater(FpjsProPlugin.getVisitorId(), throwsException);
    });

    test('getVisitorData', () async {
      await expectLater(FpjsProPlugin.getVisitorData(), throwsException);
    });
  });
}
