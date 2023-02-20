// ignore_for_file: non_constant_identifier_names

@JS('FingerprintJSFlutter')
library fingerprint_js;

import 'package:js/js.dart';

@JS('FingerprintJS')
class FingerprintJS {
  external static Future<FingerprintJSAgent> load(FingerprintJSOptions options);
  external static String get ERROR_NETWORK_CONNECTION;
  external static String get ERROR_NETWORK_ABORT;
  external static String get ERROR_API_KEY_MISSING;
  external static String get ERROR_API_KEY_INVALID;
  external static String get ERROR_API_KEY_EXPIRED;
  external static String get ERROR_BAD_REQUEST_FORMAT;
  external static String get ERROR_BAD_RESPONSE_FORMAT;
  external static String get ERROR_GENERAL_SERVER_FAILURE;
  external static String get ERROR_CLIENT_TIMEOUT;
  external static String get ERROR_SERVER_TIMEOUT;
  external static String get ERROR_RATE_LIMIT;
  external static String get ERROR_FORBIDDEN_ORIGIN;
  external static String get ERROR_FORBIDDEN_HEADER;
  external static String get ERROR_FORBIDDEN_ENDPOINT;
  external static String get ERROR_WRONG_REGION;
  external static String get ERROR_SUBSCRIPTION_NOT_ACTIVE;
  external static String get ERROR_UNSUPPORTED_VERSION;
  external static String get ERROR_SCRIPT_LOAD_FAIL;
  external static String get ERROR_INSTALLATION_METHOD_RESTRICTED;
  external static String get ERROR_CSP_BLOCK;
  external static String get ERROR_INTEGRATION_FAILURE;
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
  external IdentificationResultConfidenceScore confidence;
  external String? errorMessage;
}

@JS()
@anonymous
class IdentificationExtendedResult extends IdentificationResult {
  external bool visitorFound;
  external String ip;
  external IdentificationResultIpLocation? ipLocation;
  external String os;
  external String osVersion;
  external String device;
  external IdentificationResultStSeenAt firstSeenAt;
  external IdentificationResultStSeenAt lastSeenAt;
}

@JS()
@anonymous
class IdentificationResultConfidenceScore {
  external num score;
}

@JS()
@anonymous
class IdentificationResultIpLocation {
  external num accuracyRadius;
  external num latitude;
  external num longitude;
  external String postalCode;
  external String timezone;
  external IdentificationResultCity city;
  external IdentificationResultCountry country;
  external IdentificationResultContinent continent;
  external List<IdentificationResultSubdivision> subdivisions;
}

@JS()
@anonymous
class IdentificationResultCity {
  external String name;
}

@JS()
@anonymous
class IdentificationResultCountry {
  external String code;
  external String name;
}

@JS()
@anonymous
class IdentificationResultContinent {
  external String code;
  external String name;
}

@JS()
@anonymous
class IdentificationResultSubdivision {
  external String isoCode;
  external String name;
}

@JS()
@anonymous
class IdentificationResultStSeenAt {
  external String? global;
  external String? subscription;
}

@JS()
@anonymous
class FingerprintJSOptions {
  external String get apiKey;
  external List<String> get integrationInfo;

  external String? get region;
  external set region(String? region);

  external String? get endpoint;
  external set endpoint(String? endpoint);

  external String? get scriptUrlPattern;
  external set scriptUrlPattern(String? scriptUrlPattern);

  external factory FingerprintJSOptions(
      {String apiKey, List<String> integrationInfo});
}

@JS()
@anonymous
class FingerprintJSGetOptions {
  external Map<String, dynamic>? get tag;
  external String? get linkedId;
  external bool extendedResult;

  external factory FingerprintJSGetOptions(
      {Object? tag, String? linkedId, bool extendedResult = false});
}

@JS()
@anonymous
class WebException {
  external String get message;
  external String? get requestId;
}
