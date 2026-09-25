// JSONTypeConvertor maps Pigeon tag values to Fingerprint.JSONType.
// https://docs.fingerprint.com/docs/tagging-information

import Foundation
import Fingerprint
import XCTest

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
