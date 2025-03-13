// ignore_for_file: non_constant_identifier_names

/// JavaScript interop for the [FingerprintJS Pro JavaScript agent](https://dev.fingerprint.com/docs/js-agent)
@JS('FingerprintJSFlutter')
library fingerprint_js;

import 'dart:js_interop';

/// FingerprintJS Pro library namespace
extension type FingerprintJS._(JSObject _) implements JSObject {
  /// Loads JS Agent script to the webpage and initialize it
  external static JSPromise<FingerprintJSAgent> load(
      FingerprintJSOptions options);
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
extension type FingerprintJSAgent._(JSObject _) implements JSObject {
  /// Gets the visitor identifier.
  /// When an error is emitted by the backend, it gets a `requestId` field, same as in successful result.
  external JSPromise<IdentificationResult> get(FingerprintJSGetOptions options);
}

/// Result of getting a visitor id.
///
/// `visitorId` can be empty string when the visitor can't be identified.
/// It happens only with bots and hackers that modify their browsers.
extension type IdentificationResult._(JSObject _) implements JSObject {
  /// The visitor identifier
  external String visitorId;

  /// If true, this visitor was found and visited before.
  /// If false, this visitor wasn't found and probably didn't visit before.
  external bool visitorFound;

  /// The current request identifier. It's different for every request.
  external String requestId;

  /// A confidence score that tells how much the agent is sure about the visitor identifier
  external IdentificationResultConfidenceScore confidence;

  /// Sealed result, which is an encrypted content of the `/events` Server API response for this requestId, encoded in
  /// base64. The field will miss if Sealed Results are disabled or unavailable for another reason.
  external String? sealedResult;
}

/// Result of requesting a visitor id when requested with `extendedResponseFormat: true`
extension type IdentificationExtendedResult._(IdentificationResult _)
    implements IdentificationResult {
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
extension type IdentificationResultConfidenceScore._(JSObject _)
    implements JSObject {
  /// A number between 0 and 1 that tells how much the agent is sure about the visitor identifier.
  /// The higher the number, the higher the chance of the visitor identifier to be true.
  external num score;

  /// Additional details about the score as a human-readable text
  external String? comment;
}

/// IP address location. Can be empty for anonymous proxies.
extension type IdentificationResultIpLocation._(JSObject _)
    implements JSObject {
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
  external JSArray<IdentificationResultSubdivision>? subdivisions;
}

/// City, when available
extension type IdentificationResultCity._(JSObject _) implements JSObject {
  external String name;
}

/// Country, when available. Will be missing for Tor/anonymous proxies.
extension type IdentificationResultCountry._(JSObject _) implements JSObject {
  external String code;
  external String name;
}

/// Continent, when available. Will be missing for Tor/anonymous proxies.
extension type IdentificationResultContinent._(JSObject _) implements JSObject {
  external String code;
  external String name;
}

/// Administrative subdivision (for example states|provinces -> counties|parishes).
/// Can contain only top-level administrative units within a country, e.g. a state.
extension type IdentificationResultSubdivision._(JSObject _)
    implements JSObject {
  external String isoCode;
  external String name;
}

/// When the visitor was seen
extension type IdentificationResultStSeenAt._(JSObject _) implements JSObject {
  /// The date and time across all subscription. The string format is ISO-8601.
  external String? global;

  /// The date and time within your subscription. The string format is ISO-8601.
  external String? subscription;
}

/// Options that need to load JS Agent
extension type FingerprintJSOptions._(JSObject _) implements JSObject {
  /// Public API key
  external String get apiKey;

  /// Information about libraries and services used to integrate the JS agent.
  /// Each array item means a separate integration, the order doesn't matter.
  /// An example of an integration library is FingerprintJS Pro React.
  external JSArray<JSString> get integrationInfo;

  /// Region of the FingerprintJS service server
  external String? get region;
  external set region(String? region);

  /// Your custom API endpoint for getting visitor data.
  external JSArray<JSString>? get endpoint;
  external set endpoint(JSArray<JSString>? endpoint);

  /// A JS agent script URL pattern.
  ///
  /// The following substrings are replaced:
  /// - <version> — the major version of JS agent;
  /// - <apiKey> — the public key set via the `apiKey` option;
  /// - <loaderVersion> — the version of this package;
  external JSArray<JSString>? get scriptUrlPattern;
  external set scriptUrlPattern(JSArray<JSString>? scriptUrlPattern);

  external factory FingerprintJSOptions(
      {String apiKey, JSArray<JSString> integrationInfo});
}

/// Options of getting a visitor identifier.
extension type FingerprintJSGetOptions._(JSObject _) implements JSObject {
  /// `Tag` is a user-provided value or object that will be returned back to you in a webhook message.
  /// You may want to use the `tag` value to be able to associate a server-side webhook event with a web request of the
  /// current visitor.
  ///
  /// What values can be used as a `tag`?
  /// Anything that identifies a visitor or a request.
  /// You can pass the requestId as a `tag` and then get this requestId back in the webhook, associated with a visitorId.
  external JSObject? get tag;

  /// `linkedId` is a way of linking current identification event with a custom identifier.
  /// This can be helpful to be able to filter API visit information later.
  external String? get linkedId;

  /// Adds details about the visitor to the result
  external bool extendedResult;

  /// Controls client-side timeout. Client timeout controls total time (both client-side and server-side) that any
  /// identification event is allowed to run. It doesn't include time when the page is in background (not visible).
  /// The value is in milliseconds.
  external int? get timeout;

  external factory FingerprintJSGetOptions(
      {JSObject? tag, String? linkedId, int? timeout, bool extendedResult});
}

/// Interop for JS Agent exceptions
extension type WebException._(JSObject _) implements JSObject {
  external String get message;
  external String? get requestId;
}
