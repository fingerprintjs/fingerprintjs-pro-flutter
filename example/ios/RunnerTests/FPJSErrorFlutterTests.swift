// Verifies native SDK errors exposed through the Pigeon contract.

@preconcurrency import Fingerprint
import XCTest

@testable import fpjs_pro_plugin

final class FPJSErrorFlutterTests: XCTestCase {
  func testRemovesUnknownEventIdAndMessage() throws {
    let error = try makeAPIError(
      code: .publicApiKeyRequired,
      eventId: "Unknown",
      message: "Unknown"
    )

    let fields = FPError.apiError(error).pigeonFields()

    XCTAssertEqual(fields.code, "public_api_key_required")
    XCTAssertNil(fields.message)
    XCTAssertNil(fields.eventId)
  }

  func testKeepsRealEventIdAndMessage() throws {
    let error = try makeAPIError(
      code: .publicApiKeyRequired,
      eventId: "event-id",
      message: "API key is required"
    )

    let fields = FPError.apiError(error).pigeonFields()

    XCTAssertEqual(fields.code, "public_api_key_required")
    XCTAssertEqual(fields.message, "API key is required")
    XCTAssertEqual(fields.eventId, "event-id")
  }
}
