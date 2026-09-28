// Runs without a Flutter binding on purpose, like an app that creates the
// client in main() before runApp(). Keep TestWidgetsFlutterBinding out of
// this file.
import 'package:flutter_test/flutter_test.dart';
import 'package:fingerprint_flutter/fingerprint_flutter.dart';

void main() {
  test('constructor throws when the Flutter binding does not exist', () {
    expect(() => Fingerprint(apiKey: 'key-1'), throwsFlutterError);
  });
}
