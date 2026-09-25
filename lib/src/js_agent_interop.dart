/// JavaScript interop for the v4 [@fingerprint/agent](https://docs.fingerprint.com/reference/js-agent-start-function).
@JS('FingerprintFlutter')
library;

import 'dart:js_interop';

/// `FingerprintFlutter.Fingerprint` from the bundled loader.
@JS('Fingerprint')
extension type FingerprintLoader._(JSObject _) implements JSObject {
  external static FingerprintAgent start(JSObject options);
}

/// Agent instance returned by [FingerprintLoader.start].
extension type FingerprintAgent(JSObject _) implements JSObject {
  external JSPromise<JSObject> get([JSObject? options]);
}

/// Identification payload. Fields besides [eventId] may be omitted.
/// https://docs.fingerprint.com/reference/js-agent-get-function
extension type JSGetResult(JSObject _) implements JSObject {
  @JS('event_id')
  external String get eventId;

  @JS('visitor_id')
  external String? get visitorId;

  @JS('suspect_score')
  external int? get suspectScore;

  // Omitted, a base64 string, or BinaryOutput. No Dart union type.
  @JS('sealed_result')
  external JSAny? get sealedResult;

  @JS('cache_hit')
  external JSBoolean? get cacheHit;
}

/// `sealed_result` wrapper. `base64()` and `toString()` both return base64.
/// https://docs.fingerprint.com/reference/js-agent-get-function
extension type JSBinaryOutput(JSObject _) implements JSObject {
  external String base64();
}
