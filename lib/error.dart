import 'package:flutter/services.dart';

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

class InstallationMethodRestrictedError extends FingerprintProError {
  InstallationMethodRestrictedError(String? message)
      : super('InstallationMethodRestrictedError', message);
}

/// Error while parsing the response
class ResponseCannotBeParsedError extends FingerprintProError {
  ResponseCannotBeParsedError(String? message)
      : super('ResponseCannotBeParsedError', message);
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

/// Other error
class UnknownError extends FingerprintProError {
  UnknownError(String? message) : super('UnknownError', message);
}

FingerprintProError unwrapError(PlatformException error) {
  switch (error.code) {
    case 'InvalidURL':
      return InvalidUrlError(error.message);
    case 'InvalidURLParams':
      return InvalidURLParamsError(error.message);
    case 'ApiError':
      return ApiError(error.message);
    // Api Errors block
    case 'ApiKeyRequired':
    case 'TokenRequired':
      return ApiKeyRequiredError(error.message);
    case 'ApiKeyNotFound':
    case 'TokenNotFound':
      return ApiKeyNotFoundError(error.message);
    case 'ApiKeyExpired':
    case 'TokenExpired':
      return ApiKeyExpiredError(error.message);
    case 'RequestCannotBeParsed':
      return RequestCannotBeParsedError(error.message);
    case 'Failed':
      return FailedError(error.message);
    case 'RequestTimeout':
      return RequestTimeoutError(error.message);
    case 'TooManyRequest':
      return TooManyRequestError(error.message);
    case 'OriginNotAvailable':
      return OriginNotAvailableError(error.message);
    case 'HeaderRestricted':
      return HeaderRestrictedError(error.message);
    case 'HostnameRestricted':
      return HostnameRestrictedError(error.message);
    case 'NotAvailableForCrawlBots':
      return NotAvailableForCrawlBotsError(error.message);
    case 'NotAvailableWithoutUA':
      return NotAvailableWithoutUAError(error.message);
    case 'WrongRegion':
      return WrongRegionError(error.message);
    case 'SubscriptionNotActive':
      return SubscriptionNotActiveError(error.message);
    case 'UnsupportedVersion':
      return UnsupportedVersionError(error.message);
    case 'InstallationMethodRestricted':
      return InstallationMethodRestrictedError(error.message);
    case 'ResponseCannotBeParsed':
      return ResponseCannotBeParsedError(error.message);
    // end of API Errors block
    case 'NetworkError':
      return NetworkError(error.message);
    case 'JsonParsingError':
      return JsonParsingError(error.message);
    case 'InvalidResponseType':
      return InvalidResponseTypeError(error.message);
    default:
      return UnknownError(error.message);
  }
}
