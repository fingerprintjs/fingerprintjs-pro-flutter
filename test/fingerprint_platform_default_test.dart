import 'package:flutter_test/flutter_test.dart';
import 'package:fpjs_pro_plugin/src/fingerprint_platform_interface.dart';
import 'package:fpjs_pro_plugin/src/fingerprint_native.dart';

void main() {
  test('uses FingerprintNative by default', () {
    expect(FingerprintPlatform.instance, isA<FingerprintNative>());
  });
}
