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
enum NativeRegion { us, eu, ap }

class FingerprintNativeConfig {
  FingerprintNativeConfig({
    required this.apiKey,
    required this.region,
    this.endpoints,
    required this.pluginVersion,
    required this.allowUseOfLocationData,
    this.locationTimeoutMillis,
  });

  String apiKey;
  NativeRegion region;
  // Null or non-empty. The native SDKs take the first as the primary
  // endpoint and the rest as fallbacks.
  List<String>? endpoints;
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

// All methods share one serial background queue:
// - creating the native client can be slow, keep it off the UI thread
// - serial keeps calls in order, so create runs before a later get
// https://pub.dev/packages/pigeon#task-queue
@HostApi()
abstract class FingerprintHostApi {
  /// Builds the native client early, so SDK startup work (such as iOS
  /// location collection) begins before the first get. get carries the
  /// config too and builds the client if create did not run.
  /// https://docs.fingerprint.com/docs/ios-sdk#using-location-data-for-proximity-detection
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  void create(FingerprintNativeConfig config);

  @asyncCallback
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  FingerprintNativeResult get(
    FingerprintNativeConfig config,
    Map<String, Object?>? tags,
    String? linkedId,
    int? timeoutMs,
  );
}
