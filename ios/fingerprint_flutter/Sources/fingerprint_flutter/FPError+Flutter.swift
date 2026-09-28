import Foundation
@preconcurrency import Fingerprint

extension FPError {
  /// Snake_case code and message for Pigeon [PigeonError].
  func pigeonFields() -> (code: String, message: String?, eventId: String?) {
    // FPError is not LocalizedError. localizedDescription is Foundation's
    // generic "couldn't be completed" string.
    // https://developer.apple.com/documentation/foundation/localizederror
    let description = self.description
    // Client-side codes match the JS agent codes for the same failure.
    // https://docs.fingerprint.com/reference/js-agent-v4-error-handling
    switch self {
    case .invalidURL:
      return ("invalid_endpoint", description, nil)
    // The plugin builds the integration info, so this is a plugin bug.
    case .invalidURLParams:
      return ("unknown_error", description, nil)
    case .apiError(let apiError):
      // rawValue is the server's snake_case code. Dart keeps codes it has
      // no constant for, so no per-code list is needed here.
      let code = apiError.errorDetails?.code?.rawValue ?? "unknown_error"
      let message = apiError.errorDetails?.message ?? description
      let eventId = normalizeEventId(apiError.eventId)
      return (code, message, eventId)
    // Inner value is usually URLError. Its localizedDescription is the
    // user-facing text. FPError.description is a debug dump of that NSError.
    case .networkError(let error):
      return ("network_error", error.localizedDescription, nil)
    // Also covers request encoding failures. Dart validates tags first, so
    // in practice this is a bad response.
    case .jsonParsingError(let error):
      return ("bad_response_format", error.localizedDescription, nil)
    case .invalidResponseType:
      return ("bad_response_format", description, nil)
    case .clientTimeout:
      return ("client_timeout", description, nil)
    // The SDK also returns unknownError when the server sends a code missing
    // from APIError.Code. The whole error body fails to decode, so the server
    // code, message, and eventId are gone before the plugin sees them.
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
