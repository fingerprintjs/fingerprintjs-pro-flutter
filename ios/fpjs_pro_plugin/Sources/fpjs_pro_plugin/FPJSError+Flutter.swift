// Maps Fingerprint.FPError to Pigeon error codes (snake_case), matching Android.

@preconcurrency import Fingerprint
import Foundation

extension FPError {
  /// Snake_case code and message for Pigeon [PigeonError].
  func pigeonFields() -> (code: String, message: String?, eventId: String?) {
    // FPError is not LocalizedError. localizedDescription is Foundation's
    // generic "couldn't be completed" string.
    // https://developer.apple.com/documentation/foundation/localizederror
    let description = self.description
    switch self {
    case .invalidURL:
      return ("invalid_url", description, nil)
    case .invalidURLParams:
      return ("invalid_url_params", description, nil)
    case .apiError(let apiError):
      let code = apiError.pigeonCode()
      let message = apiError.errorDetails?.message ?? description
      let eventId = normalizeEventId(apiError.eventId)
      return (code, message, eventId)
    // Inner value is usually URLError. Its localizedDescription is the
    // user-facing text. FPError.description is a debug dump of that NSError.
    case .networkError(let error):
      return ("network_error", error.localizedDescription, nil)
    case .jsonParsingError(let error):
      return ("json_parsing_error", error.localizedDescription, nil)
    case .invalidResponseType:
      return ("invalid_response_type", description, nil)
    case .clientTimeout:
      return ("client_timeout", description, nil)
    case .unknownError:
      fallthrough
    @unknown default:
      return ("unknown_error", description, nil)
    }
  }
}

extension APIError {
  func pigeonCode() -> String {
    guard let code = errorDetails?.code else {
      return "unknown_error"
    }
    return Self.snakeCaseCode(code)
  }

  static func snakeCaseCode(_ code: APIError.Code) -> String {
    switch code {
    case .requestCannotBeParsed: return "request_cannot_be_parsed"
    case .failed: return "failed"
    case .requestReadTimeout: return "request_read_timeout"
    case .tooManyRequests: return "too_many_requests"
    case .publicApiKeyRequired: return "public_api_key_required"
    case .publicApiKeyNotFound: return "public_api_key_not_found"
    case .subscriptionNotActive: return "subscription_not_active"
    case .subscriptionRestricted: return "subscription_restricted"
    case .wrongRegion: return "wrong_region"
    case .featureNotEnabled: return "feature_not_enabled"
    case .visitorNotFound: return "visitor_not_found"
    case .missingModule: return "missing_module"
    case .payloadTooLarge: return "payload_too_large"
    case .serviceUnavailable: return "service_unavailable"
    case .environmentRestricted: return "environment_restricted"
    case .installationMethodRestricted: return "installation_method_restricted"
    case .invalidProxyIntegrationSecret: return "invalid_proxy_integration_secret"
    case .invalidProxyIntegrationHeaders: return "invalid_proxy_integration_headers"
    case .proxyIntegrationSecretEnvironmentMismatch:
      return "proxy_integration_secret_environment_mismatch"
    case .secretApiKeyRequired: return "secret_api_key_required"
    case .secretApiKeyNotFound: return "secret_api_key_not_found"
    case .stateNotReady: return "state_not_ready"
    case .eventNotFound: return "event_not_found"
    case .rulesetNotFound: return "ruleset_not_found"
    case .subscriptionNotFound: return "subscription_not_found"
    @unknown default:
      return camelCaseToSnakeCase(code.rawValue)
    }
  }
}

func normalizeEventId(_ eventId: String?) -> String? {
  // Android Error defaults a missing id to "Unknown". That is not a server
  // event. Apply the same filter here so Dart never sees the placeholder.
  guard let eventId, !eventId.isEmpty, eventId != "Unknown" else {
    return nil
  }
  return eventId
}

private func camelCaseToSnakeCase(_ value: String) -> String {
  var result = ""
  for character in value {
    if character.isUppercase {
      if !result.isEmpty {
        result.append("_")
      }
      result.append(character.lowercased())
    } else {
      result.append(character)
    }
  }
  return result
}
