// ignore_for_file: non_constant_identifier_names

/// JavaScript interop for the [FingerprintJS Pro JavaScript agent](https://dev.fingerprint.com/docs/js-agent)
@JS('FingerprintJSFlutter')
library fingerprint_js;

import 'package:js/js.dart';

/// FingerprintJS Pro library namespace
@JS('FingerprintJS')
class FingerprintJS {
  /// Loads JS Agent script to the webpage and initialize it
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

/// FingerprintJS Pro [JavaScript agent](https://dev.fingerprint.com/docs/js-agent)
@JS()
@anonymous
class FingerprintJSAgent {
  /// Gets the visitor identifier.
  /// When an error is emitted by the backend, it gets a `requestId` field, same as in successful result.
  external Future<IdentificationResult> get(FingerprintJSGetOptions options);
}

/// Result of getting a visitor id.
///
/// `visitorId` can be empty string when the visitor can't be identified.
/// It happens only with bots and hackers that modify their browsers.
@JS()
@anonymous
class IdentificationResult {
  /// The visitor identifier
  external String visitorId;

  /// If true, this visitor was found and visited before.
  /// If false, this visitor wasn't found and probably didn't visit before.
  external bool visitorFound;

  /// The current request identifier. It's different for every request.
  external String requestId;

  /// A confidence score that tells how much the agent is sure about the visitor identifier
  external IdentificationResultConfidenceScore confidence;
}

/// Result of requesting a visitor id when requested with `extendedResponseFormat: true`
@JS()
@anonymous
class IdentificationExtendedResult extends IdentificationResult {
  /// Whether the visitor is in incognito/private mode
  external bool incognito;

  /// Browser name
  external String browserName;

  /// Browser version
  external String browserVersion;

  /// IP address. IPv4 or IPv6.
  external String ip;

  /// IP address location. Can be empty for anonymous proxies
  external IdentificationResultIpLocation? ipLocation;

  /// OS name
  external String os;

  /// OS version
  external String osVersion;

  /// Device.
  /// For desktop/laptop devices, the value will be "Other"
  external String device;

  /// When the visitor was seen for the first time
  external IdentificationResultStSeenAt firstSeenAt;

  /// When the visitor was seen previous time
  external IdentificationResultStSeenAt lastSeenAt;
}

/// A confidence score that tells how much the agent is sure about the visitor identifier
@JS()
@anonymous
class IdentificationResultConfidenceScore {
  /// A number between 0 and 1 that tells how much the agent is sure about the visitor identifier.
  /// The higher the number, the higher the chance of the visitor identifier to be true.
  external num score;

  /// Additional details about the score as a human-readable text
  external String? comment;
}

/// IP address location. Can be empty for anonymous proxies.
@JS()
@anonymous
class IdentificationResultIpLocation {
  /// IP address location detection radius. Smaller values (<50mi) are business/residential,
  /// medium values (50 < x < 500) are cellular towers (usually),
  /// larger values (>= 500) are cloud IPs or proxies, VPNs.
  /// Can be missing, in case of Tor/proxies.
  external num? accuracyRadius;

  /// Latitude
  /// Can be missing, in case of Tor/proxies.
  external num? latitude;

  /// Longitude
  /// Can be missing, in case of Tor/proxies.
  external num? longitude;

  /// Postal code, when available
  external String? postalCode;

  /// Timezone of the IP address location
  external String? timezone;

  /// City, when available
  external IdentificationResultCity? city;

  /// Country, when available. Will be missing for Tor/anonymous proxies.
  external IdentificationResultCountry? country;

  /// Continent, when available. Will be missing for Tor/anonymous proxies.
  external IdentificationResultContinent? continent;

  /// Administrative subdivisions array (for example states|provinces -> counties|parishes).
  /// Can be empty or missing.
  /// When not empty, can contain only top-level administrative units within a country, e.g. a state.
  external List<IdentificationResultSubdivision>? subdivisions;
}

/// City, when available
@JS()
@anonymous
class IdentificationResultCity {
  external String name;
}

/// Country, when available. Will be missing for Tor/anonymous proxies.
@JS()
@anonymous
class IdentificationResultCountry {
  external String code;
  external String name;
}

/// Continent, when available. Will be missing for Tor/anonymous proxies.
@JS()
@anonymous
class IdentificationResultContinent {
  external String code;
  external String name;
}

/// Administrative subdivision (for example states|provinces -> counties|parishes).
/// Can contain only top-level administrative units within a country, e.g. a state.
@JS()
@anonymous
class IdentificationResultSubdivision {
  external String isoCode;
  external String name;
}

/// When the visitor was seen
@JS()
@anonymous
class IdentificationResultStSeenAt {
  /// The date and time across all subscription. The string format is ISO-8601.
  external String? global;

  /// The date and time within your subscription. The string format is ISO-8601.
  external String? subscription;
}

/// Options that need to load JS Agent
@JS()
@anonymous
class FingerprintJSOptions {
  /// Public API key
  external String get apiKey;

  /// Information about libraries and services used to integrate the JS agent.
  /// Each array item means a separate integration, the order doesn't matter.
  /// An example of an integration library is FingerprintJS Pro React.
  external List<String> get integrationInfo;

  /// Region of the FingerprintJS service server
  external String? get region;
  external set region(String? region);

  /// Your custom API endpoint for getting visitor data.
  external String? get endpoint;
  external set endpoint(String? endpoint);

  /// A JS agent script URL pattern.
  ///
  /// The following substrings are replaced:
  /// - <version> — the major version of JS agent;
  /// - <apiKey> — the public key set via the `apiKey` option;
  /// - <loaderVersion> — the version of this package;
  external String? get scriptUrlPattern;
  external set scriptUrlPattern(String? scriptUrlPattern);

  external factory FingerprintJSOptions(
      {String apiKey, List<String> integrationInfo});
}

/// Options of getting a visitor identifier.
@JS()
@anonymous
class FingerprintJSGetOptions {
  /// `Tag` is a user-provided value or object that will be returned back to you in a webhook message.
  /// You may want to use the `tag` value to be able to associate a server-side webhook event with a web request of the
  /// current visitor.
  ///
  /// What values can be used as a `tag`?
  /// Anything that identifies a visitor or a request.
  /// You can pass the requestId as a `tag` and then get this requestId back in the webhook, associated with a visitorId.
  external Map<String, dynamic>? get tag;

  /// `linkedId` is a way of linking current identification event with a custom identifier.
  /// This can be helpful to be able to filter API visit information later.
  external String? get linkedId;

  /// Adds details about the visitor to the result
  external bool extendedResult;

  external factory FingerprintJSGetOptions(
      {Object? tag, String? linkedId, bool extendedResult = false});
}

/// Interop for JS Agent exceptions
@JS()
@anonymous
class WebException {
  external String get message;
  external String? get requestId;
}
