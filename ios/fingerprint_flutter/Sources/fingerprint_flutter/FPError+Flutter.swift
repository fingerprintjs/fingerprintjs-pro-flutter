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
      // rawValue is the code string the server sent.
      let code = apiError.errorDetails?.code?.rawValue ?? "unknown_error"
      let message = apiError.errorDetails?.message ?? description
      // Same as Android: Dart gets nil, not an empty id.
      let eventId = apiError.eventId.isEmpty ? nil : apiError.eventId
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
    // Also used for server codes missing from APIError.Code.
    case .unknownError:
      fallthrough
    @unknown default:
      return ("unknown_error", description, nil)
    }
  }
}
