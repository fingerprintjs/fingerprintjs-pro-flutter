// Verifies native SDK errors exposed through the Pigeon contract.

@preconcurrency import Fingerprint
import Foundation
import Testing

@testable import fingerprint_flutter

struct FPErrorFlutterTests {
  @Test(arguments: [
    ("Unknown", nil),
    ("event-id", "event-id"),
  ] as [(String, String?)])
  func keepsCodeAndMessageAndDropsUnknownEventId(eventId: String, expectedEventId: String?)
    throws
  {
    let error = try makeAPIError(
      code: .publicApiKeyRequired,
      eventId: eventId,
      message: "API key is required"
    )

    let fields = FPError.apiError(error).pigeonFields()

    #expect(fields.code == "public_api_key_required")
    #expect(fields.message == "API key is required")
    #expect(fields.eventId == expectedEventId)
  }

  // Literal server strings, not APIError.Code.rawValue, so this fails if the
  // plugin stops forwarding the server's code as is.
  @Test(arguments: [
    "too_many_requests",
    "request_read_timeout",
    "public_api_key_not_found",
    "secret_api_key_required",  // no Dart constant, still passed through
  ])
  func forwardsServerCodeUnchanged(serverCode: String) throws {
    let json = #"{"version":"v4","event_id":"event-id","error":{"code":"\#(serverCode)","message":"message"}}"#
    let apiError = try JSONDecoder().decode(APIError.self, from: Data(json.utf8))

    #expect(FPError.apiError(apiError).pigeonFields().code == serverCode)
  }
}
