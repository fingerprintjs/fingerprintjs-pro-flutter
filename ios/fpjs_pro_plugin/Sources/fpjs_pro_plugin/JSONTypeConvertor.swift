// Converts Flutter/Pigeon tag values to Fingerprint.JSONType.
// JSON null is JSONType.null. Nested maps often arrive as [AnyHashable: Any].
// https://docs.fingerprint.com/docs/tagging-information

import Foundation
@preconcurrency import Fingerprint

func jsonType(from object: Any?) -> JSONType? {
  guard let object else {
    return .null
  }
  if object is NSNull {
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
  if let entries = stringKeyedEntries(object) {
    var result: [String: JSONType] = [:]
    for (key, value) in entries {
      if let converted = jsonType(from: value) {
        result[key] = converted
      }
    }
    return .object(result)
  }
  return nil
}

private func stringKeyedEntries(_ object: Any) -> [(String, Any?)]? {
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
