// Example app startup states. Identification itself runs in the Maestro flows
// in example/maestro.
import 'package:env_flutter/env_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fingerprint_flutter_example/main.dart';

void main() {
  testWidgets('shows the error and disables buttons without an API key', (
    WidgetTester tester,
  ) async {
    dotenv.testLoad(envFilesAsStrings: const ['']);
    await tester.pumpWidget(const MyApp());

    // Maestro waits for this text to fail fast on a broken setup.
    expect(
      find.textContaining('Failed to create Fingerprint client:'),
      findsOneWidget,
    );
    for (final label in _buttonLabels) {
      expect(_button(tester, label).onPressed, isNull);
    }
  });

  testWidgets('enables buttons when the client is created', (
    WidgetTester tester,
  ) async {
    dotenv.testLoad(envFilesAsStrings: const ['API_KEY=test-api-key']);
    await tester.pumpWidget(const MyApp());

    expect(find.text('Fingerprint client created'), findsOneWidget);
    for (final label in _buttonLabels) {
      expect(_button(tester, label).onPressed, isNotNull);
    }
  });
}

const _buttonLabels = ['Run tests!', 'Identify!', 'Get visitor data!'];

ElevatedButton _button(WidgetTester tester, String label) =>
    tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, label));
