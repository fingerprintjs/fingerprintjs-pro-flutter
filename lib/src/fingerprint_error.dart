// The identification error shared by Android, iOS, and web.

/// An identification request that failed.
///
/// [code] uses the snake_case value reported by the identification client.
/// Compare it with the constants on this class. New native SDK or web agent
/// versions may report other values, which remain available unchanged.
///
/// Platform adapters translate native errors into this type. They also remove
/// platform-only sentinel values before constructing it. This keeps platform
/// rules out of the public error type.
final class FingerprintError implements Exception {
  // Server errors returned by identification.
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
  static const visitorNotFound = 'visitor_not_found';
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

  // Client errors shared by one or more platforms.
  static const responseCannotBeParsed = 'response_cannot_be_parsed';
  static const invalidUrl = 'invalid_url';
  static const invalidUrlParams = 'invalid_url_params';
  static const networkError = 'network_error';
  static const jsonParsingError = 'json_parsing_error';
  static const invalidResponseType = 'invalid_response_type';
  static const clientTimeout = 'client_timeout';
  static const unknownError = 'unknown_error';

  // Web agent errors.
  static const sandboxedIframe = 'sandboxed_iframe';
  static const cspBlock = 'csp_block';
  static const invalidEndpoint = 'invalid_endpoint';
  static const handleAgentData = 'handle_agent_data';
  static const scriptLoadFail = 'script_load_fail';
  static const bundleNotDefined = 'bundle_not_defined';
  static const badResponseFormat = 'bad_response_format';
  static const serverError = 'server_error';
  static const apiKeyMissing = 'api_key_missing';
  static const apiKeyInvalid = 'api_key_invalid';
  static const cacheMisconfigured = 'cache_misconfigured';
  static const endpointsMisconfigured = 'endpoints_misconfigured';
  static const wrongWorkerOption = 'wrong_worker_option';
  static const workerInitializationFailed = 'worker_initialization_failed';

  /// The machine-readable error code.
  ///
  /// This is not limited to the known constants. Keeping an unfamiliar code
  /// lets applications log or handle an error added by a newer client.
  final String code;

  /// What the client said went wrong, if it said anything.
  final String? message;

  /// The server event associated with the failure, if the client reported it.
  final String? eventId;

  /// Creates an error from values normalized by a platform adapter.
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
