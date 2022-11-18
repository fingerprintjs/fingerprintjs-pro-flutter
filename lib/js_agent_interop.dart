@JS('FingerprintJSFlutter')
library fingerprint_js;

import 'package:flutter/cupertino.dart';
import 'package:js/js.dart';


@JS('FingerprintJS')
class FingerprintJS {
  external static Future<FingerprintJSAgent> load(FingerprintJSOptions options);
}

@JS()
@anonymous
class FingerprintJSAgent {
  external Future<IdentificationResult> get(FingerprintJSGetOptions options);
}

@JS()
@anonymous
class IdentificationResult {
  external String visitorId;
  external String requestId;
}

@JS()
@anonymous
class FingerprintJSOptions {
  external String get apiKey;
  external String? get region;
  // external String? get endpoint;

  external factory FingerprintJSOptions({String apiKey, String? region/*, String? endpoint*/});
}

@JS()
@anonymous
class FingerprintJSGetOptions {
  external Map<String, dynamic>? get tag;
  external String? get linkedId;
  external bool extendedResult;

  external factory FingerprintJSGetOptions({Map<String, dynamic>? tag, String? linkedId, bool extendedResult = false});
}

