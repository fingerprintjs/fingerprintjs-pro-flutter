import Foundation
@preconcurrency import Fingerprint

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
      // The SDK decodes the server's code string into APIError.Code, so
      // rawValue is exactly what the server sent. No per-code mapping needed.
      let code = apiError.errorDetails?.code?.rawValue ?? "unknown_error"
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
    // Also what the SDK returns for a server code missing from APIError.Code.
    case .unknownError:
      fallthrough
    @unknown default:
      return ("unknown_error", description, nil)
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
