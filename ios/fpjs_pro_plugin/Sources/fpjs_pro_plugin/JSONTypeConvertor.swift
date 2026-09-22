// Converts Flutter/Pigeon tag values to Fingerprint.JSONType.
// JSON null is JSONType.null. Nested maps often arrive as [AnyHashable: Any].
// https://docs.fingerprint.com/docs/tagging-information

import Foundation
@preconcurrency import Fingerprint

class JSONTypeConvertor {
  static func convert(_ object: Any?) -> JSONType? {
    guard let object else {
      return .null
    }
    if object is NSNull {
      return .null
    }
    if let value = object as? Int {
      return .int(value)
    }
    if let value = object as? Double {
      return .double(value)
    }
    if let value = object as? String {
      return .string(value)
    }
    if let value = object as? Bool {
      return .bool(value)
    }
    if let array = object as? [Any] {
      return .array(array.compactMap(convert))
    }
    if let array = object as? [Any?] {
      return .array(array.compactMap(convert))
    }
    if let entries = stringKeyedEntries(object) {
      var result: [String: JSONType] = [:]
      for (key, value) in entries {
        if let converted = convert(value) {
          result[key] = converted
        }
      }
      return .object(result)
    }
    return nil
  }

  private static func stringKeyedEntries(_ object: Any) -> [(String, Any?)]? {
    if let dict = object as? [String: Any?] {
      return Array(dict)
    }
    if let dict = object as? [AnyHashable: Any?] {
      return dict.compactMap { key, value in
        (key as? String).map { ($0, value) }
      }
    }
    if let dict = object as? [AnyHashable: Any] {
      return dict.compactMap { key, value in
        (key as? String).map { ($0, value) }
      }
    }
    return nil
  }
}
