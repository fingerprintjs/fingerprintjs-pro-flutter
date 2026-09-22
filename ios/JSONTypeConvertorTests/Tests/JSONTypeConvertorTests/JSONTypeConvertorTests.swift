// JSONTypeConvertor maps Pigeon tag values to Fingerprint.JSONType.
// https://docs.fingerprint.com/docs/tagging-information

import Foundation
import Fingerprint
import XCTest

final class JSONTypeConvertorTests: XCTestCase {
  func testConvertsJSONNull() {
    XCTAssertEqual(JSONTypeConvertor.convert(nil), .null)
    XCTAssertEqual(JSONTypeConvertor.convert(NSNull()), .null)

    XCTAssertEqual(
      JSONTypeConvertor.convert(["campaign": nil as Any?, "sessionId": 1]),
      .object([
        "campaign": .null,
        "sessionId": .int(1),
      ])
    )
    XCTAssertEqual(
      JSONTypeConvertor.convert(["campaign": NSNull(), "sessionId": 1]),
      .object([
        "campaign": .null,
        "sessionId": .int(1),
      ])
    )
  }

  func testConvertsFlutterNSNumberBoolsAndInts() {
    XCTAssertEqual(JSONTypeConvertor.convert(kCFBooleanTrue), .bool(true))
    XCTAssertEqual(JSONTypeConvertor.convert(kCFBooleanFalse), .bool(false))
    XCTAssertEqual(JSONTypeConvertor.convert(NSNumber(value: 1)), .int(1))
    XCTAssertEqual(JSONTypeConvertor.convert(NSNumber(value: 0)), .int(0))
  }

  func testConvertsNestedAnyHashableMaps() {
    let inner: [AnyHashable: Any] = ["campaign": NSNull()]
    let outer: [AnyHashable: Any] = ["meta": inner, "ok": true]

    XCTAssertEqual(
      JSONTypeConvertor.convert(outer),
      .object([
        "meta": .object(["campaign": .null]),
        "ok": .bool(true),
      ])
    )
  }
}
