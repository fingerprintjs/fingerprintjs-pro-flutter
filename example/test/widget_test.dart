import 'package:env_flutter/env_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpjs_pro_plugin/fpjs_pro_plugin.dart';
import 'package:fpjs_pro_plugin_example/main.dart';

void main() {
  const channel = MethodChannel(FpjsProPlugin.channelName);

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('disables controls when initialization fails',
      (WidgetTester tester) async {
    dotenv.testLoad(envFilesAsStrings: const ['']);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Failed to initialize Fingerprint agent:'),
      findsOneWidget,
    );
    expect(_button(tester, runChecksButtonKey).onPressed, isNull);
    expect(_button(tester, identifyButtonKey).onPressed, isNull);
    expect(_button(tester, identifyExtendedButtonKey).onPressed, isNull);
  });

  testWidgets('enables controls when initialization succeeds',
      (WidgetTester tester) async {
    final calls = _mockSuccessfulInitialization(channel);
    dotenv.testLoad(envFilesAsStrings: const ['API_KEY=test-api-key']);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Fingerprint agent ready'), findsOneWidget);
    expect(calls.single.arguments['allowUseOfLocationData'], isTrue);
    expect(_button(tester, runChecksButtonKey).onPressed, isNotNull);
    expect(_button(tester, identifyButtonKey).onPressed, isNotNull);
    expect(_button(tester, identifyExtendedButtonKey).onPressed, isNotNull);
  });

  testWidgets('can disable location collection for native automation',
      (WidgetTester tester) async {
    final calls = _mockSuccessfulInitialization(channel);
    dotenv.testLoad(envFilesAsStrings: const [
      'API_KEY=test-api-key\nDISABLE_LOCATION_COLLECTION=true',
    ]);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Fingerprint agent ready'), findsOneWidget);
    expect(calls.single.arguments['allowUseOfLocationData'], isFalse);
  });
}

ElevatedButton _button(WidgetTester tester, Key key) {
  return tester.widget<ElevatedButton>(find.byKey(key));
}

List<MethodCall> _mockSuccessfulInitialization(MethodChannel channel) {
  final calls = <MethodCall>[];
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async {
    calls.add(call);
    return null;
  });
  return calls;
}
