// Converts Flutter/Pigeon tag values to Fingerprint.JSONType.
// JSON null is JSONType.null. Nested maps often arrive as [AnyHashable: Any].
// https://docs.fingerprint.com/docs/tagging-information

import Foundation
@preconcurrency import Fingerprint

func jsonType(from object: Any?) -> JSONType? {
  guard let object, !(object is NSNull) else {
    return .null
  }
  // A nil optional boxed in `Any` (from `[Any?]` or `[K: Any?]`) passes `guard let`
  // and matches no cast below.
  let mirror = Mirror(reflecting: object)
  if mirror.displayStyle == .optional, mirror.children.isEmpty {
    return .null
  }
  // Flutter bools are CFBoolean NSNumbers. `as? Int` turns them into 0/1,
  // and `as? Bool` also matches integer NSNumbers. Check CFBoolean first.
  // https://developer.apple.com/documentation/corefoundation/cfboolean
  if let number = object as? NSNumber {
    if CFGetTypeID(number) == CFBooleanGetTypeID() {
      return .bool(number.boolValue)
    }
    if CFNumberIsFloatType(number) {
      return .double(number.doubleValue)
    }
    return .int(number.intValue)
  }
  if let value = object as? String {
    return .string(value)
  }
  if let value = object as? Bool {
    return .bool(value)
  }
  if let value = object as? Int {
    return .int(value)
  }
  if let value = object as? Double {
    return .double(value)
  }
  if let array = object as? [Any?] {
    return .array(array.compactMap { jsonType(from: $0) })
  }
  // Also matches [String: Any] and [AnyHashable: Any]. Non-string keys are dropped.
  if let dict = object as? [AnyHashable: Any?] {
    var result: [String: JSONType] = [:]
    for (key, value) in dict {
      if let key = key as? String, let converted = jsonType(from: value) {
        result[key] = converted
      }
    }
    return .object(result)
  }
  return nil
}
