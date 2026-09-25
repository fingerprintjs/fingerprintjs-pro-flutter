import 'package:flutter_test/flutter_test.dart';
import 'package:fingerprint_flutter/src/fingerprint_platform_interface.dart';
import 'package:fingerprint_flutter/src/fingerprint_native.dart';

void main() {
  test('uses FingerprintNative by default', () {
    expect(FingerprintPlatform.instance, isA<FingerprintNative>());
  });
}
