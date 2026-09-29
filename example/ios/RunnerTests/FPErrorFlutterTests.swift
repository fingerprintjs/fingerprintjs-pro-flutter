// Verifies native SDK errors exposed through the Pigeon contract.

@preconcurrency import Fingerprint
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
}
