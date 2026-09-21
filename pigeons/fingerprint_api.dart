// Native identification contract. Run:
// dart run pigeon --input pigeons/fingerprint_api.dart
//
// @asyncCallback (not @async): Pigeon 28's Swift `Task` for @async fails
// Swift 6 isolation. Dart still gets a Future.
// https://pub.dev/packages/pigeon#synchronous-and-asynchronous-methods

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/pigeon/fingerprint_api.g.dart',
  dartPackageName: 'fpjs_pro_plugin',
  kotlinOut:
      'android/src/main/kotlin/com/fingerprintjs/flutter/fpjs_pro/fpjs_pro_plugin/FingerprintApi.g.kt',
  kotlinOptions: KotlinOptions(
    package: 'com.fingerprintjs.flutter.fpjs_pro.fpjs_pro_plugin',
  ),
  swiftOut: 'ios/fpjs_pro_plugin/Sources/fpjs_pro_plugin/FingerprintApi.g.swift',
))
class FingerprintNativeConfig {
  FingerprintNativeConfig({
    required this.apiKey,
    this.region,
    this.endpoints,
    required this.pluginVersion,
    required this.allowUseOfLocationData,
    this.locationTimeoutMillis,
  });

  String apiKey;
  String? region;
  List<String>? endpoints;
  String pluginVersion;
  bool allowUseOfLocationData;
  int? locationTimeoutMillis;
}

class FingerprintNativeResult {
  FingerprintNativeResult({
    required this.eventId,
    required this.visitorId,
    this.suspectScore,
    this.sealedResult,
  });

  String eventId;
  String visitorId;
  int? suspectScore;
  String? sealedResult;
}

@HostApi()
abstract class FingerprintHostApi {
  @asyncCallback
  FingerprintNativeResult get(
    FingerprintNativeConfig config,
    Map<Object?, Object?>? tags,
    String? linkedId,
    int? timeoutMs,
  );
}
