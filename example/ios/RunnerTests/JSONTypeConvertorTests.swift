// Verifies Pigeon tag values are converted to Fingerprint JSON values.
// https://docs.fingerprint.com/docs/tagging-information

@preconcurrency import Fingerprint
import Foundation
import Testing

@testable import fingerprint_flutter

struct JSONTypeConvertorTests {
  @Test func convertsJSONNull() {
    #expect(jsonType(from: nil) == .null)
    #expect(jsonType(from: NSNull()) == .null)

    #expect(
      jsonType(from: ["campaign": nil as Any?, "sessionId": 1])
        == .object([
          "campaign": .null,
          "sessionId": .int(1),
        ])
    )
    #expect(
      jsonType(from: ["campaign": NSNull(), "sessionId": 1])
        == .object([
          "campaign": .null,
          "sessionId": .int(1),
        ])
    )
    #expect(
      jsonType(from: [nil, NSNull(), 1] as [Any?]) == .array([.null, .null, .int(1)])
    )
  }

  @Test func convertsNilBoxedInAny() {
    let boxedNil: Any = Optional<Int>.none as Any

    #expect(jsonType(from: boxedNil) == .null)
    #expect(
      jsonType(from: ["campaign": boxedNil] as [AnyHashable: Any])
        == .object(["campaign": .null])
    )
    #expect(jsonType(from: [boxedNil, 1] as [Any]) == .array([.null, .int(1)]))
  }

  @Test func convertsFlutterNSNumberBoolsAndInts() {
    #expect(jsonType(from: kCFBooleanTrue) == .bool(true))
    #expect(jsonType(from: kCFBooleanFalse) == .bool(false))
    #expect(jsonType(from: NSNumber(value: 1)) == .int(1))
    #expect(jsonType(from: NSNumber(value: 0)) == .int(0))
  }

  @Test func convertsNestedAnyHashableMaps() {
    let inner: [AnyHashable: Any] = ["campaign": NSNull()]
    let outer: [AnyHashable: Any] = ["meta": inner, "ok": true]

    #expect(
      jsonType(from: outer)
        == .object([
          "meta": .object(["campaign": .null]),
          "ok": .bool(true),
        ])
    )
  }
}
