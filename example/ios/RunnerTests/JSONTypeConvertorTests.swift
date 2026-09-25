// Verifies Pigeon tag values are converted to Fingerprint JSON values.
// https://docs.fingerprint.com/docs/tagging-information

@preconcurrency import Fingerprint
import Foundation
import XCTest

@testable import fpjs_pro_plugin

final class JSONTypeConvertorTests: XCTestCase {
  func testConvertsJSONNull() {
    XCTAssertEqual(jsonType(from: nil), .null)
    XCTAssertEqual(jsonType(from: NSNull()), .null)

    XCTAssertEqual(
      jsonType(from: ["campaign": nil as Any?, "sessionId": 1]),
      .object([
        "campaign": .null,
        "sessionId": .int(1),
      ])
    )
    XCTAssertEqual(
      jsonType(from: ["campaign": NSNull(), "sessionId": 1]),
      .object([
        "campaign": .null,
        "sessionId": .int(1),
      ])
    )
    XCTAssertEqual(
      jsonType(from: [nil, NSNull(), 1] as [Any?]),
      .array([.null, .null, .int(1)])
    )
  }

  func testConvertsFlutterNSNumberBoolsAndInts() {
    XCTAssertEqual(jsonType(from: kCFBooleanTrue), .bool(true))
    XCTAssertEqual(jsonType(from: kCFBooleanFalse), .bool(false))
    XCTAssertEqual(jsonType(from: NSNumber(value: 1)), .int(1))
    XCTAssertEqual(jsonType(from: NSNumber(value: 0)), .int(0))
  }

  func testConvertsNestedAnyHashableMaps() {
    let inner: [AnyHashable: Any] = ["campaign": NSNull()]
    let outer: [AnyHashable: Any] = ["meta": inner, "ok": true]

    XCTAssertEqual(
      jsonType(from: outer),
      .object([
        "meta": .object(["campaign": .null]),
        "ok": .bool(true),
      ])
    )
  }
}
