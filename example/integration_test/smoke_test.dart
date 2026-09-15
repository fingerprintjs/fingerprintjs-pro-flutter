import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:fpjs_pro_plugin_example/main.dart' as app;

// Soak instrumentation. `SOAK_VARIANT` selects which candidate mitigation for the
// mid-test semantics handle is under test:
//   plain        - control, no mitigation
//   simdefault   - accessibility forced on in the simulator before launch (see workflow)
//   presemantics - the app takes a semantics handle before the test starts
const soakVariant = String.fromEnvironment('SOAK_VARIANT', defaultValue: 'plain');

String _semantics() {
  final platform = WidgetsBinding.instance.platformDispatcher.semanticsEnabled;
  final binding = SemanticsBinding.instance;
  return 'platform=$platform framework=${binding.semanticsEnabled} '
      'handles=${binding.debugOutstandingSemanticsHandles}';
}

void _probe(String label) => debugPrint('SEMPROBE $label ${_semantics()}');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  _probe('after-binding-init');
  if (soakVariant == 'presemantics') {
    // Never disposed on purpose: the point is to hold semantics on for the whole
    // process, so the platform cannot flip it on midway through the test.
    SemanticsBinding.instance.ensureSemantics();
    _probe('after-ensure-semantics');
  }

  testWidgets('runs the example app smoke flow', (WidgetTester tester) async {
    _probe('test-start');
    await app.main();
    await tester.pumpAndSettle();

    await _waitForText(
      tester,
      app.initializationStatusKey,
      (text) => text == 'Fingerprint agent ready',
      description: 'Fingerprint agent to initialize',
      failure: (text) => text.startsWith('Failed to initialize'),
    );

    await tester.tap(find.byKey(app.runChecksButtonKey));
    await _waitForText(
      tester,
      app.checksResultKey,
      (text) => text == 'Success!',
      description: 'example checks to succeed',
      failure: (text) => text.startsWith('Failed:'),
    );

    await tester.tap(find.byKey(app.identifyButtonKey));
    await _waitForText(
      tester,
      app.deviceIdResultKey,
      (text) => text.isNotEmpty && text != 'Unknown',
      description: 'a device ID',
      failure: (text) => text.startsWith('Failed'),
    );
    final deviceId = tester
        .widget<Text>(find.byKey(app.deviceIdResultKey))
        .data!;

    await tester.tap(find.byKey(app.visitorDataButtonKey));
    await _waitFor(
      tester,
      () => find.byKey(app.visitorDataDialogKey).evaluate().isNotEmpty,
      description: 'visitor data dialog',
    );

    final result = tester
        .widget<Text>(find.byKey(app.visitorDataContentKey))
        .data
        .toString();
    final visitorData = jsonDecode(result) as Map<String, dynamic>;
    expect(visitorData['visitorId'], deviceId);
    _probe('test-end');
  }, timeout: const Timeout(Duration(minutes: 5)));
}

Future<void> _waitForText(
  WidgetTester tester,
  Key key,
  bool Function(String text) matches, {
  required String description,
  bool Function(String text)? failure,
}) {
  return _waitFor(tester, () {
    final finder = find.byKey(key);
    if (finder.evaluate().isEmpty) return false;
    final text = tester.widget<Text>(finder).data ?? '';
    if (failure?.call(text) ?? false) {
      fail('Failed waiting for $description: $text');
    }
    return matches(text);
  }, description: description);
}

Future<void> _waitFor(
  WidgetTester tester,
  bool Function() condition, {
  required String description,
}) async {
  final deadline = DateTime.now().add(const Duration(seconds: 90));
  var lastSemantics = _semantics();
  while (!condition()) {
    final semantics = _semantics();
    if (semantics != lastSemantics) {
      debugPrint('SEMPROBE changed-during-wait($description) $semantics');
      lastSemantics = semantics;
    }
    if (DateTime.now().isAfter(deadline)) {
      fail('Timed out waiting for $description');
    }
    await tester.pump(const Duration(milliseconds: 250));
  }
}
