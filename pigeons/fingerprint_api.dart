// Native identification contract. Run:
// dart run pigeon --input pigeons/fingerprint_api.dart
//
// @asyncCallback (not @async): Pigeon 28's Swift `Task` for @async fails
// Swift 6 isolation. Dart still gets a Future.
// https://pub.dev/packages/pigeon#synchronous-and-asynchronous-methods

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeon/fingerprint_api.g.dart',
    dartPackageName: 'fingerprint_flutter',
    kotlinOut:
        'android/src/main/kotlin/com/fingerprint/flutter/FingerprintApi.g.kt',
    kotlinOptions: KotlinOptions(package: 'com.fingerprint.flutter'),
    swiftOut:
        'ios/fingerprint_flutter/Sources/fingerprint_flutter/FingerprintApi.g.swift',
  ),
)
class FingerprintNativeConfig {
  FingerprintNativeConfig({
    required this.apiKey,
    this.region,
    this.endpoint,
    this.endpointFallbacks,
    required this.pluginVersion,
    required this.allowUseOfLocationData,
    this.locationTimeoutMillis,
  });

  String apiKey;
  String? region;
  // Public API is one `endpoints` list. Native still splits first + rest.
  String? endpoint;
  List<String>? endpointFallbacks;
  String pluginVersion;
  bool allowUseOfLocationData;
  int? locationTimeoutMillis;
}

/// Pigeon copy of the Android/iOS SDK identification response.
///
/// `visitorId` is `String` because those SDKs always send a string. Empty means
/// hidden. Dart `FingerprintResult` turns empty into null.
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
  /// Builds the native Fingerprint client immediately so location can warm
  /// before identification. get still carries config and reuses this client,
  /// so two Dart clients stay independent if create was skipped.
  /// https://docs.fingerprint.com/docs/ios-sdk
  void create(FingerprintNativeConfig config);

  @asyncCallback
  FingerprintNativeResult get(
    FingerprintNativeConfig config,
    Map<String?, Object?>? tags,
    String? linkedId,
    int? timeoutMs,
  );
}
