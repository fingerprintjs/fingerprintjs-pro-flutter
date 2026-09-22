import 'package:flutter_test/flutter_test.dart';
import 'package:fpjs_pro_plugin/src/fingerprint_platform_interface.dart';
import 'package:fpjs_pro_plugin/src/method_channel_fingerprint.dart';

void main() {
  test('uses the method channel implementation by default', () {
    expect(FingerprintPlatform.instance, isA<MethodChannelFingerprint>());
  });
}
