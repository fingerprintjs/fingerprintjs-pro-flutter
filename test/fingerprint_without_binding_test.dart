// Runs without a Flutter binding on purpose, like an app that starts the
// client in main() before runApp(). Keep TestWidgetsFlutterBinding out of
// this file.
@TestOn('vm')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:fingerprint_flutter/fingerprint_flutter.dart';

void main() {
  test('start throws when the Flutter binding does not exist', () async {
    final client = Fingerprint(apiKey: 'key-1');
    await expectLater(client.start(), throwsFlutterError);
  });
}
