// The identification request error shared by Android, iOS, and web.

/// [code] is the client's snake_case value. Compare it with the constants on
/// this class. Other strings are kept.
///
/// Server codes without a constant here: iOS and web pass them through as is.
/// Android sends [unknownError] with the server message, because the Android
/// SDK has no code string to forward.
///
/// On Android and iOS, a server code the native SDK does not know arrives as
/// [unknownError] and the server message is lost. Android still sets
/// [eventId], so the event can be looked up.
///
/// Platform code builds this after replacing SDK placeholders (e.g. Android
/// "Unknown" event ids) with null.
final class FingerprintError implements Exception {
  // Server errors returned by Identification API.
  static const failed = 'failed';
  static const requestCannotBeParsed = 'request_cannot_be_parsed';
  static const requestReadTimeout = 'request_read_timeout';
  static const tooManyRequests = 'too_many_requests';
  static const publicApiKeyRequired = 'public_api_key_required';
  static const publicApiKeyNotFound = 'public_api_key_not_found';
  static const subscriptionNotActive = 'subscription_not_active';
  static const subscriptionRestricted = 'subscription_restricted';
  static const wrongRegion = 'wrong_region';
  static const featureNotEnabled = 'feature_not_enabled';
  static const missingModule = 'missing_module';
  static const payloadTooLarge = 'payload_too_large';
  static const serviceUnavailable = 'service_unavailable';
  static const environmentRestricted = 'environment_restricted';
  static const installationMethodRestricted = 'installation_method_restricted';
  static const invalidProxyIntegrationSecret =
      'invalid_proxy_integration_secret';
  static const invalidProxyIntegrationHeaders =
      'invalid_proxy_integration_headers';
  static const proxyIntegrationSecretEnvironmentMismatch =
      'proxy_integration_secret_environment_mismatch';

  // Client errors on every platform.
  static const networkError = 'network_error';
  static const clientTimeout = 'client_timeout';
  static const unknownError = 'unknown_error';

  // Client errors on iOS and Android. Same codes as the React Native SDK.
  static const invalidUrl = 'invalid_url';
  static const invalidUrlParams = 'invalid_url_params';
  static const jsonParsingError = 'json_parsing_error';
  static const invalidResponseType = 'invalid_response_type';
  static const responseCannotBeParsed = 'response_cannot_be_parsed';

  // JavaScript agent errors from its public docs, minus codes for options the
  // plugin does not expose (worker, non-string apiKey).
  // https://docs.fingerprint.com/reference/js-agent-v4-error-handling
  static const sandboxedIframe = 'sandboxed_iframe';
  static const cspBlock = 'csp_block';
  static const invalidEndpoint = 'invalid_endpoint';
  static const scriptLoadFail = 'script_load_fail';
  static const badResponseFormat = 'bad_response_format';
  static const apiKeyMissing = 'api_key_missing';
  static const cacheMisconfigured = 'cache_misconfigured';
  static const endpointsMisconfigured = 'endpoints_misconfigured';

  /// The machine-readable error code. Not limited to the constants above.
  final String code;

  /// What the client said went wrong, if it said anything.
  final String? message;

  /// The identification event ID for this failure, if the client reported one.
  final String? eventId;

  /// Creates an error from values a platform adapter already normalized.
  ///
  /// An empty code becomes [unknownError]. Empty optional strings become null.
  FingerprintError({required String code, String? message, String? eventId})
    : code = code.isEmpty ? unknownError : code,
      message = (message == null || message.isEmpty) ? null : message,
      eventId = (eventId == null || eventId.isEmpty) ? null : eventId;

  @override
  String toString() {
    final parts = [
      code,
      if (message != null) message,
      if (eventId != null) 'eventId: $eventId',
    ];
    return 'FingerprintError(${parts.join(', ')})';
  }
}
