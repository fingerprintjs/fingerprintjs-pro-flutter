import 'error.dart';
import 'js_agent_interop.dart';

FingerprintProError unwrapWebError(WebException error) {
  final message = error.message;

  if (message == FingerprintJS.ERROR_NETWORK_CONNECTION) {
    return NetworkError(message);
  }
  if (message == FingerprintJS.ERROR_NETWORK_ABORT) {
    return NetworkError(message);
  }
  if (message == FingerprintJS.ERROR_API_KEY_MISSING) {
    return ApiKeyRequiredError(message);
  }
  if (message == FingerprintJS.ERROR_API_KEY_INVALID) {
    return ApiKeyNotFoundError(message);
  }
  if (message == FingerprintJS.ERROR_API_KEY_EXPIRED) {
    return ApiKeyExpiredError(message);
  }
  if (message == FingerprintJS.ERROR_BAD_REQUEST_FORMAT) {
    return RequestCannotBeParsedError(message);
  }
  if (message == FingerprintJS.ERROR_BAD_RESPONSE_FORMAT) {
    return ResponseCannotBeParsedError(message);
  }
  if (message == FingerprintJS.ERROR_GENERAL_SERVER_FAILURE) {
    return FailedError(message);
  }
  if (message == FingerprintJS.ERROR_CLIENT_TIMEOUT) {
    return RequestTimeoutError(message);
  }
  if (message == FingerprintJS.ERROR_SERVER_TIMEOUT) {
    return RequestTimeoutError(message);
  }
  if (message == FingerprintJS.ERROR_RATE_LIMIT) {
    return TooManyRequestError(message);
  }
  if (message == FingerprintJS.ERROR_FORBIDDEN_ORIGIN) {
    return OriginNotAvailableError(message);
  }
  if (message == FingerprintJS.ERROR_FORBIDDEN_HEADER) {
    return HeaderRestrictedError(message);
  }
  if (message == FingerprintJS.ERROR_FORBIDDEN_ENDPOINT) {
    return InvalidUrlError(message);
  }
  if (message == FingerprintJS.ERROR_WRONG_REGION) {
    return WrongRegionError(message);
  }
  if (message == FingerprintJS.ERROR_SUBSCRIPTION_NOT_ACTIVE) {
    return SubscriptionNotActiveError(message);
  }
  if (message == FingerprintJS.ERROR_UNSUPPORTED_VERSION) {
    return UnsupportedVersionError(message);
  }
  if (message == FingerprintJS.ERROR_SCRIPT_LOAD_FAIL) {
    return ScriptLoadFailError(message);
  }
  if (message == FingerprintJS.ERROR_INSTALLATION_METHOD_RESTRICTED) {
    return InstallationMethodRestrictedError(message);
  }
  if (message == FingerprintJS.ERROR_CSP_BLOCK) {
    return CspBlockError(message);
  }
  if (message == FingerprintJS.ERROR_INTEGRATION_FAILURE) {
    return IntegrationFailureError(message);
  }

  return UnknownError(message);
}
