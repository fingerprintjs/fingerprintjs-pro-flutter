/// Every error code the v4 Android SDK, iOS SDK, or web agent can report.
///
/// This enum is the error matrix. Each member carries the raw code string the
/// platforms send. The codes are the API's own snake_case error keys, which is
/// what the web agent already reports and what the Android SDK keys its error
/// classes off, so one code covers all three platforms even where the native
/// types are named differently. The React Native SDK uses the same vocabulary.
///
/// The `Platforms` line on each member says which platforms can emit it, and
/// names the native type behind it wherever that name disagrees with the code.
/// A code this enum does not list maps to [FingerprintErrorCode.unknown], and
/// the original string stays on [FingerprintError.rawCode], so a newer native
/// SDK or agent never costs information.
///
/// The members are grouped as the platforms group them. The grouping decides
/// whether an event id is available: a server error is a reply to a request the
/// server accepted and assigned an id, so it can carry
/// [FingerprintError.eventId]. A client error never reached the server, so it
/// cannot.
enum FingerprintErrorCode {
  // ---------------------------------------------------------------------------
  // Server errors. The request reached the API, which rejected it. These may
  // carry an event id.
  // ---------------------------------------------------------------------------

  /// The server failed for a reason it did not report.
  ///
  /// Platforms: Android, iOS, web.
  failed('failed'),

  /// The server could not parse the request.
  ///
  /// Platforms: Android, iOS, web.
  requestCannotBeParsed('request_cannot_be_parsed'),

  /// The server timed out reading the request body.
  ///
  /// Platforms: Android, iOS, web. Android names the class `RequestTimeout`,
  /// but the factory builds it from this same `request_read_timeout` key.
  requestReadTimeout('request_read_timeout'),

  /// The API key ran out of requests.
  ///
  /// Platforms: Android, iOS, web.
  tooManyRequests('too_many_requests'),

  /// The request carried no public API key.
  ///
  /// Platforms: Android, iOS, web.
  publicApiKeyRequired('public_api_key_required'),

  /// The public API key does not exist.
  ///
  /// Platforms: Android, iOS, web.
  publicApiKeyNotFound('public_api_key_not_found'),

  /// The endpoint expected a secret API key, which a client SDK never sends.
  ///
  /// Reachable through a misconfigured proxy integration.
  ///
  /// Platforms: Android, iOS, web.
  secretApiKeyRequired('secret_api_key_required'),

  /// The secret API key does not exist.
  ///
  /// Platforms: Android, iOS, web.
  secretApiKeyNotFound('secret_api_key_not_found'),

  /// The subscription behind the API key is not active.
  ///
  /// Platforms: Android, iOS, web.
  subscriptionNotActive('subscription_not_active'),

  /// The subscription behind the API key does not exist.
  ///
  /// Platforms: Android, iOS.
  subscriptionNotFound('subscription_not_found'),

  /// The subscription does not allow this request.
  ///
  /// Platforms: Android, iOS.
  subscriptionRestricted('subscription_restricted'),

  /// The API key belongs to a different region than the one configured.
  ///
  /// Platforms: Android, iOS, web.
  wrongRegion('wrong_region'),

  /// The subscription does not include a feature the request used.
  ///
  /// Platforms: Android, iOS, web.
  featureNotEnabled('feature_not_enabled'),

  /// The requested visitor does not exist.
  ///
  /// Platforms: Android, iOS, web.
  visitorNotFound('visitor_not_found'),

  /// The requested event does not exist.
  ///
  /// Platforms: Android, iOS, web. Android still names the class
  /// `RequestNotFound`, from before events were called events, but the factory
  /// builds it from this same `event_not_found` key.
  eventNotFound('event_not_found'),

  /// The requested request id does not exist.
  ///
  /// Distinct from [eventNotFound] despite the Android class name: this is the
  /// agent's own code for a lookup by request id.
  ///
  /// Platforms: web.
  requestNotFound('request_not_found'),

  /// The request needs a module the subscription does not have.
  ///
  /// Platforms: Android, iOS, web.
  missingModule('missing_module'),

  /// The request body exceeded the size the server accepts.
  ///
  /// Tags are the usual cause: the
  /// [limit](https://docs.fingerprint.com/docs/tagging-information) is 16 KB
  /// and it is enforced here, on the server, not by this SDK.
  ///
  /// Platforms: Android, iOS, web.
  payloadTooLarge('payload_too_large'),

  /// The service is temporarily unavailable.
  ///
  /// Platforms: Android, iOS.
  serviceUnavailable('service_unavailable'),

  /// The server is not ready to answer for this visitor yet.
  ///
  /// Platforms: Android, iOS, web.
  stateNotReady('state_not_ready'),

  /// The requested ruleset does not exist.
  ///
  /// Platforms: Android, iOS.
  rulesetNotFound('ruleset_not_found'),

  /// The environment in the request does not exist or is not allowed.
  ///
  /// Platforms: Android, iOS.
  environmentRestricted('environment_restricted'),

  /// The subscription does not allow this SDK's installation method.
  ///
  /// Platforms: Android, iOS.
  installationMethodRestricted('installation_method_restricted'),

  /// The proxy integration secret is invalid.
  ///
  /// Platforms: Android, iOS.
  invalidProxyIntegrationSecret('invalid_proxy_integration_secret'),

  /// The proxy integration headers are invalid.
  ///
  /// Platforms: Android, iOS.
  invalidProxyIntegrationHeaders('invalid_proxy_integration_headers'),

  /// The proxy integration secret belongs to a different environment.
  ///
  /// Platforms: Android, iOS.
  proxyIntegrationSecretEnvironmentMismatch(
      'proxy_integration_secret_environment_mismatch'),

  /// The page ran the agent inside a sandboxed iframe.
  ///
  /// Platforms: web.
  sandboxedIframe('sandboxed_iframe'),

  // ---------------------------------------------------------------------------
  // Client errors, Android and iOS. These are raised by the SDK rather than the
  // API, so they carry no event id, apart from [responseCannotBeParsed], where
  // the answer arrived but could not be read.
  // ---------------------------------------------------------------------------

  /// The SDK could not read the server's answer.
  ///
  /// The one client error that can carry an event id, since the request did
  /// reach the server.
  ///
  /// Platforms: Android.
  responseCannotBeParsed('response_cannot_be_parsed'),

  /// The SDK could not build the identification URL.
  ///
  /// Platforms: iOS.
  invalidUrl('invalid_url'),

  /// The SDK could not build the identification URL from the given parameters.
  ///
  /// Platforms: iOS.
  invalidUrlParams('invalid_url_params'),

  /// The request failed at the network layer.
  ///
  /// Platforms: Android, iOS.
  networkError('network_error'),

  /// The device had no network connection.
  ///
  /// Platforms: Android.
  networkUnavailable('network_unavailable'),

  /// The SDK could not parse the response as JSON.
  ///
  /// Platforms: iOS.
  jsonParsingError('json_parsing_error'),

  /// The response was JSON, but not of the expected shape.
  ///
  /// Platforms: iOS.
  invalidResponseType('invalid_response_type'),

  /// The request exceeded the timeout the caller asked for.
  ///
  /// Platforms: Android, iOS, web.
  clientTimeout('client_timeout'),

  // ---------------------------------------------------------------------------
  // Client errors, web agent. These carry no event id.
  // ---------------------------------------------------------------------------

  /// The browser could not reach the endpoint.
  ///
  /// Platforms: web.
  networkConnection('network_connection'),

  /// The browser aborted the request, usually because the page went away.
  ///
  /// Platforms: web.
  networkAbort('network_abort'),

  /// The page's Content Security Policy blocked the agent.
  ///
  /// Platforms: web.
  cspBlock('csp_block'),

  /// The configured endpoint is not a usable URL.
  ///
  /// Platforms: web.
  invalidEndpoint('invalid_endpoint'),

  /// The agent could not process the data it collected.
  ///
  /// Platforms: web.
  handleAgentData('handle_agent_data'),

  /// The agent script could not be loaded.
  ///
  /// Platforms: web.
  scriptLoadFail('script_load_fail'),

  /// The agent script loaded but did not define its bundle.
  ///
  /// Platforms: web.
  bundleNotDefined('bundle_not_defined'),

  /// The agent received a response it could not read.
  ///
  /// Platforms: web.
  badResponseFormat('bad_response_format'),

  /// The agent's own server call failed.
  ///
  /// Platforms: web.
  serverError('server_error'),

  /// No API key was passed to the agent.
  ///
  /// Platforms: web.
  apiKeyMissing('api_key_missing'),

  /// The API key passed to the agent is not usable.
  ///
  /// Platforms: web.
  apiKeyInvalid('api_key_invalid'),

  /// The cache configuration is not valid.
  ///
  /// Platforms: web.
  cacheMisconfigured('cache_misconfigured'),

  /// The endpoint configuration is not valid.
  ///
  /// Platforms: web.
  endpointsMisconfigured('endpoints_misconfigured'),

  /// The agent's worker option is not valid.
  ///
  /// Platforms: web.
  wrongWorkerOption('wrong_worker_option'),

  /// The agent could not start its worker.
  ///
  /// Platforms: web.
  workerInitializationFailed('worker_initialization_failed'),

  // ---------------------------------------------------------------------------
  // Fallback.
  // ---------------------------------------------------------------------------

  /// No code this enum lists matched.
  ///
  /// Either the platform reported `unknown_error` itself, or it reported
  /// something newer than this table. Read [FingerprintError.rawCode] to tell
  /// the two apart.
  ///
  /// Platforms: Android, iOS, web.
  unknown('unknown_error');

  const FingerprintErrorCode(this.rawCode);

  /// The string the platforms use for this code.
  final String rawCode;

  static final Map<String, FingerprintErrorCode> _byRawCode = {
    for (final code in FingerprintErrorCode.values) code.rawCode: code
  };

  /// The code [rawCode] names, or [unknown] if this table does not list it.
  static FingerprintErrorCode fromRawCode(String rawCode) =>
      _byRawCode[rawCode] ?? unknown;
}

/// An identification request that failed.
///
/// The constructor normalizes the per-platform sentinels, so a missing message
/// or event id is null on every platform rather than an empty string here and
/// the word `Unknown` there.
///
/// Implements [Exception] rather than extending an exception class: the type
/// needs no inherited implementation, only the contract. See the
/// [Dart core library docs](https://dart.dev/libraries/dart-core#exceptions).
final class FingerprintError implements Exception {
  /// What went wrong, as one of the codes this SDK knows.
  ///
  /// [FingerprintErrorCode.unknown] when [rawCode] is not in the matrix.
  final FingerprintErrorCode code;

  /// The code exactly as the platform reported it.
  ///
  /// Worth logging: when [code] is [FingerprintErrorCode.unknown] this is the
  /// only description of what happened.
  final String rawCode;

  /// What the platform said went wrong, if it said anything.
  final String? message;

  /// The event this failure belongs to, if the server assigned one.
  ///
  /// Null for every client error, and for a server error the platform did not
  /// attribute. Use it to look the event up in the
  /// [Server API](https://dev.fingerprint.com/reference/getevent).
  final String? eventId;

  /// The event id Android sends when the request never reached the server.
  static const _unknownEventId = 'Unknown';

  /// Creates an error from what a platform reported.
  ///
  /// An empty [rawCode] becomes [FingerprintErrorCode.unknown]'s raw code,
  /// since it describes nothing. An empty [message] becomes null. An empty
  /// [eventId], or the literal `Unknown` that Android sends when the request
  /// never reached the server, becomes null.
  FingerprintError({
    required String rawCode,
    String? message,
    String? eventId,
  })  : code = FingerprintErrorCode.fromRawCode(rawCode),
        rawCode =
            rawCode.isEmpty ? FingerprintErrorCode.unknown.rawCode : rawCode,
        message = (message == null || message.isEmpty) ? null : message,
        eventId = (eventId == null ||
                eventId.isEmpty ||
                eventId == _unknownEventId)
            ? null
            : eventId;

  /// Creates an error for a failure that reported no code at all.
  ///
  /// The web implementation needs this: the agent can reject with a value that
  /// is not one of its own errors.
  FingerprintError.unknown([String? message])
      : this(rawCode: FingerprintErrorCode.unknown.rawCode, message: message);

  @override
  String toString() {
    final parts = [
      rawCode,
      if (message != null) message,
      if (eventId != null) 'eventId: $eventId',
    ];
    return 'FingerprintError(${parts.join(', ')})';
  }
}
