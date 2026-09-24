import 'package:env_flutter/env_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpjs_pro_plugin/result.dart';
import 'package:fpjs_pro_plugin/src/fingerprint_platform_interface.dart';
import 'package:fpjs_pro_plugin_example/main.dart';

void main() {
  late RecordingFingerprint platform;
  late FingerprintPlatform previousPlatform;

  setUp(() {
    platform = RecordingFingerprint();
    previousPlatform = FingerprintPlatform.instance;
    FingerprintPlatform.instance = platform;
  });

  tearDown(() {
    FingerprintPlatform.instance = previousPlatform;
  });

  testWidgets('disables controls when initialization fails', (
    WidgetTester tester,
  ) async {
    dotenv.testLoad(envFilesAsStrings: const ['']);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Failed to initialize Fingerprint agent:'),
      findsOneWidget,
    );
    expect(_button(tester, runChecksButtonKey).onPressed, isNull);
    expect(_button(tester, identifyButtonKey).onPressed, isNull);
    expect(_button(tester, visitorDataButtonKey).onPressed, isNull);
  });

  testWidgets('enables controls when initialization succeeds', (
    WidgetTester tester,
  ) async {
    dotenv.testLoad(envFilesAsStrings: const ['API_KEY=test-api-key']);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Fingerprint agent ready'), findsOneWidget);
    expect(platform.config?.allowUseOfLocationData, isTrue);
    expect(_button(tester, runChecksButtonKey).onPressed, isNotNull);
    expect(_button(tester, identifyButtonKey).onPressed, isNotNull);
    expect(_button(tester, visitorDataButtonKey).onPressed, isNotNull);
  });

  testWidgets('can disable location collection for native automation', (
    WidgetTester tester,
  ) async {
    dotenv.testLoad(
      envFilesAsStrings: const [
        'API_KEY=test-api-key\nDISABLE_LOCATION_COLLECTION=true',
      ],
    );

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Fingerprint agent ready'), findsOneWidget);
    expect(platform.config?.allowUseOfLocationData, isFalse);
  });
}

ElevatedButton _button(WidgetTester tester, Key key) {
  return tester.widget<ElevatedButton>(find.byKey(key));
}

class RecordingFingerprint extends FingerprintPlatform {
  FingerprintConfig? config;

  @override
  Future<void> init(FingerprintConfig config) async {
    this.config = config;
  }

  @override
  Future<String?> getVisitorId({
    Map<String, dynamic>? tags,
    String? linkedId,
    int? timeoutMs,
  }) async {
    return 'test-visitor';
  }

  @override
  Future<FingerprintJSProResponse> getVisitorData({
    Map<String, dynamic>? tags,
    String? linkedId,
    int? timeoutMs,
  }) async {
    return FingerprintJSProResponse(
      'test-event',
      'test-visitor',
      ConfidenceScore(0),
      null,
    );
  }
}
