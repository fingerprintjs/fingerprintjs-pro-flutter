import 'package:flutter/services.dart';

/// Basic class for the identification error
abstract class FingerprintProError extends PlatformException {
  FingerprintProError(String code, String? message)
      : super(code: code, message: message);

  @override
  String toString() {
    return "$code: $message";
  }
}

/// Something was wrong while building URL for identification request
class InvalidUrlError extends FingerprintProError {
  InvalidUrlError(String? message) : super('InvalidURL', message);
}

/// Something was wrong with params while building URL for identification request
class InvalidURLParamsError extends FingerprintProError {
  InvalidURLParamsError(String? message) : super('InvalidURLParams', message);
}

/// Unknown API error
class ApiError extends FingerprintProError {
  ApiError(String? message) : super('ApiError', message);
}

/// Token is missing in the request
class ApiKeyRequiredError extends FingerprintProError {
  ApiKeyRequiredError(String? message) : super('ApiKeyRequiredError', message);
}

/// Wrong token
class ApiKeyNotFoundError extends FingerprintProError {
  ApiKeyNotFoundError(String? message) : super('ApiKeyNotFoundError', message);
}

/// API token is outdated
class ApiKeyExpiredError extends FingerprintProError {
  ApiKeyExpiredError(String? message) : super('ApiKeyExpiredError', message);
}

/// Wrong request format (content, parameters)
class RequestCannotBeParsedError extends FingerprintProError {
  RequestCannotBeParsedError(String? message)
      : super('RequestCannotBeParsedError', message);
}

/// Request failed
class FailedError extends FingerprintProError {
  FailedError(String? message) : super('FailedError', message);
}

/// Server timeout
class RequestTimeoutError extends FingerprintProError {
  RequestTimeoutError(String? message) : super('RequestTimeoutError', message);
}

/// Request limit for token reached
class TooManyRequestError extends FingerprintProError {
  TooManyRequestError(String? message) : super('TooManyRequestError', message);
}

/// Request Filtering deny origin
class OriginNotAvailableError extends FingerprintProError {
  OriginNotAvailableError(String? message)
      : super('OriginNotAvailableError', message);
}

/// Request Filtering deny some headers
class HeaderRestrictedError extends FingerprintProError {
  HeaderRestrictedError(String? message)
      : super('HeaderRestrictedError', message);
}

/// Request Filtering deny this hostname
class HostnameRestrictedError extends FingerprintProError {
  HostnameRestrictedError(String? message)
      : super('HostnameRestrictedError', message);
}

/// Request Filtering deny crawlers
class NotAvailableForCrawlBotsError extends FingerprintProError {
  NotAvailableForCrawlBotsError(String? message)
      : super('NotAvailableForCrawlBotsError', message);
}

/// Request Filtering deny empty UA
class NotAvailableWithoutUAError extends FingerprintProError {
  NotAvailableWithoutUAError(String? message)
      : super('NotAvailableWithoutUAError', message);
}

/// API key does not match the selected region
class WrongRegionError extends FingerprintProError {
  WrongRegionError(String? message) : super('WrongRegionError', message);
}

/// Subscription is not active for the provided API key
class SubscriptionNotActiveError extends FingerprintProError {
  SubscriptionNotActiveError(String? message)
      : super('SubscriptionNotActiveError', message);
}

/// Something wrong with used API version
class UnsupportedVersionError extends FingerprintProError {
  UnsupportedVersionError(String? message)
      : super('UnsupportedVersionError', message);
}

/// The installation method of the mobile agent is not allowed for the customer
class InstallationMethodRestrictedError extends FingerprintProError {
  InstallationMethodRestrictedError(String? message)
      : super('InstallationMethodRestrictedError', message);
}

/// Error while parsing the response
class ResponseCannotBeParsedError extends FingerprintProError {
  ResponseCannotBeParsedError(String? message)
      : super('ResponseCannotBeParsedError', message);
}

/// Integration headers are invalid
class InvalidProxyIntegrationHeaders extends FingerprintProError {
  InvalidProxyIntegrationHeaders(String? message)
      : super('InvalidProxyIntegrationHeaders', message);
}

/// Integration secret is invalid
class InvalidProxyIntegrationSecret extends FingerprintProError {
  InvalidProxyIntegrationSecret(String? message)
      : super('InvalidProxyIntegrationSecret', message);
}

/// Something wrong with network
class NetworkError extends FingerprintProError {
  NetworkError(String? message) : super('NetworkError', message);
}

/// Error while parsing JSON response
class JsonParsingError extends FingerprintProError {
  JsonParsingError(String? message) : super('JsonParsingError', message);
}

/// Bad response type
class InvalidResponseTypeError extends FingerprintProError {
  InvalidResponseTypeError(String? message)
      : super('InvalidResponseTypeError', message);
}

/// Failed to load the JS agent code
class ScriptLoadFailError extends FingerprintProError {
  ScriptLoadFailError(String? message) : super('ScriptLoadFailError', message);
}

/// Blocked by the Content Security Policy of the page
class CspBlockError extends FingerprintProError {
  CspBlockError(String? message) : super('CspBlockError', message);
}

/// Failure on the integration side
class IntegrationFailureError extends FingerprintProError {
  IntegrationFailureError(String? message)
      : super('IntegrationFailureError', message);
}

/// Other error
class UnknownError extends FingerprintProError {
  UnknownError(String? message) : super('UnknownError', message);
}

/// ClientTimeout error
class ClientTimeoutError extends FingerprintProError {
  ClientTimeoutError(String? message) : super('ClientTimeoutError', message);
}

/// Casts error from generic platform type to FingerprintProError
FingerprintProError unwrapError(PlatformException error) {
  switch (error.code) {
    case 'InvalidURL':
    case 'InvalidUrlError':
      return InvalidUrlError(error.message);
    case 'InvalidURLParams':
    case 'InvalidURLParamsError':
      return InvalidURLParamsError(error.message);
    case 'ApiError':
      return ApiError(error.message);
    // Api Errors block
    case 'ApiKeyRequired':
    case 'TokenRequired':
    case 'ApiKeyRequiredError':
      return ApiKeyRequiredError(error.message);
    case 'ApiKeyNotFound':
    case 'TokenNotFound':
    case 'ApiKeyNotFoundError':
      return ApiKeyNotFoundError(error.message);
    case 'ApiKeyExpired':
    case 'TokenExpired':
    case 'ApiKeyExpiredError':
      return ApiKeyExpiredError(error.message);
    case 'RequestCannotBeParsed':
    case 'RequestCannotBeParsedError':
      return RequestCannotBeParsedError(error.message);
    case 'Failed':
    case 'FailedError':
      return FailedError(error.message);
    case 'RequestTimeout':
    case 'RequestTimeoutError':
      return RequestTimeoutError(error.message);
    case 'TooManyRequest':
    case 'TooManyRequestError':
      return TooManyRequestError(error.message);
    case 'OriginNotAvailable':
    case 'OriginNotAvailableError':
      return OriginNotAvailableError(error.message);
    case 'HeaderRestricted':
    case 'HeaderRestrictedError':
      return HeaderRestrictedError(error.message);
    case 'HostnameRestricted':
    case 'HostnameRestrictedError':
      return HostnameRestrictedError(error.message);
    case 'NotAvailableForCrawlBots':
    case 'NotAvailableForCrawlBotsError':
      return NotAvailableForCrawlBotsError(error.message);
    case 'NotAvailableWithoutUA':
    case 'NotAvailableWithoutUAError':
      return NotAvailableWithoutUAError(error.message);
    case 'WrongRegion':
    case 'WrongRegionError':
      return WrongRegionError(error.message);
    case 'SubscriptionNotActive':
    case 'SubscriptionNotActiveError':
      return SubscriptionNotActiveError(error.message);
    case 'UnsupportedVersion':
    case 'UnsupportedVersionError':
      return UnsupportedVersionError(error.message);
    case 'InstallationMethodRestricted':
    case 'InstallationMethodRestrictedError':
      return InstallationMethodRestrictedError(error.message);
    case 'ResponseCannotBeParsed':
    case 'ResponseCannotBeParsedError':
      return ResponseCannotBeParsedError(error.message);
    case 'InvalidProxyIntegrationHeaders':
    case 'InvalidProxyIntegrationHeadersError':
      return InvalidProxyIntegrationHeaders(error.message);
    case 'InvalidProxyIntegrationSecret':
    case 'InvalidProxyIntegrationSecretError':
      return InvalidProxyIntegrationSecret(error.message);
    // end of API Errors block
    case 'NetworkError':
      return NetworkError(error.message);
    case 'JsonParsingError':
      return JsonParsingError(error.message);
    case 'InvalidResponseType':
    case 'InvalidResponseTypeError':
      return InvalidResponseTypeError(error.message);
    case 'ScriptLoadFailError':
      return ScriptLoadFailError(error.message);
    case 'CspBlockError':
      return CspBlockError(error.message);
    case 'IntegrationFailureError':
      return IntegrationFailureError(error.message);
    case 'ClientTimeout':
    case 'ClientTimeoutError':
      return ClientTimeoutError(error.message);
    default:
      return UnknownError(error.message);
  }
}
