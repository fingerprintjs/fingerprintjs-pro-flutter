// The identification request error shared by Android, iOS, and web.

/// [code] is the client's snake_case value. Compare it with the constants on
/// this class. Other strings are kept.
///
/// Server codes that become [unknownError]:
/// - Android: codes without a constant here. Message is kept.
/// - Android and iOS: codes the native SDK does not know. Message is lost.
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

  // iOS-only client errors, same codes as the React Native SDK.
  static const invalidUrl = 'invalid_url';
  static const invalidUrlParams = 'invalid_url_params';
  static const jsonParsingError = 'json_parsing_error';
  static const invalidResponseType = 'invalid_response_type';

  // Android-only client error, same code as the React Native SDK.
  static const responseCannotBeParsed = 'response_cannot_be_parsed';

  // JS agent ErrorCode values, minus ones the plugin cannot trigger:
  // handleAgentData, non-string apiKey, loader-internal codes, and
  // wrong_worker_option (start() has no worker option).
  // worker_initialization_failed stays: it is in the agent's public ErrorCode
  // type, so a later agent 4.x could emit it.
  // https://docs.fingerprint.com/reference/js-agent-v4-error-handling
  static const sandboxedIframe = 'sandboxed_iframe';
  static const cspBlock = 'csp_block';
  static const invalidEndpoint = 'invalid_endpoint';
  static const scriptLoadFail = 'script_load_fail';
  static const badResponseFormat = 'bad_response_format';
  static const serverError = 'server_error';
  static const apiKeyMissing = 'api_key_missing';
  static const cacheMisconfigured = 'cache_misconfigured';
  static const endpointsMisconfigured = 'endpoints_misconfigured';
  static const workerInitializationFailed = 'worker_initialization_failed';

  /// The machine-readable error code. Not limited to the constants above.
  final String code;

  /// What the client said went wrong, if it said anything.
  final String? message;

  /// The identification event ID for this failure, if the client reported one.
  final String? eventId;

  /// Creates an error. An empty [code] becomes [unknownError]. Empty
  /// [message] and [eventId] become null.
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
