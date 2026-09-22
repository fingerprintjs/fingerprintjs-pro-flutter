// JSONTypeConvertor maps Pigeon tag values to Fingerprint.JSONType.
// https://docs.fingerprint.com/docs/tagging-information

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
