/// Validation and platform-specific shaping of the `tags` argument.
///
/// A tag can be any recursively JSON-compatible value. The platforms disagree
/// on the shape they accept: Android and iOS require a map, the web agent takes
/// any JSON value. So a non-map tag is wrapped as `{'tag': value}` for native
/// and forwarded as is to the web agent. This matches the React Native SDK.
///
/// There is no size cap here. The
/// [16 KB limit](https://docs.fingerprint.com/docs/tagging-information) is a
/// server-side product limit reported as `payload_too_large`.
library;

/// The key a non-map tag is wrapped under before it is sent to Android or iOS.
const wrappedTagKey = 'tag';

/// Validates [tags] and returns the value to send to Android and iOS.
///
/// Both native SDKs take a map, so anything else, scalars and lists alike, is
/// wrapped as `{'tag': tags}`. Returns null for null, meaning no tags.
///
/// Throws an [ArgumentError] if [tags] is not recursively JSON-compatible.
Map<String, Object?>? tagsForNative(Object? tags) {
  if (tags == null) {
    return null;
  }
  validateTags(tags);
  if (tags is Map<Object?, Object?>) {
    // Copied rather than cast, so the result is a plain map even when the
    // caller passed one that is not statically string-keyed.
    return {for (final entry in tags.entries) entry.key as String: entry.value};
  }
  return {wrappedTagKey: tags};
}

/// Validates [tags] and returns the value to forward to the web agent.
///
/// The web agent accepts any JSON value, so nothing is wrapped. Returns null
/// for null, meaning no tags.
///
/// Throws an [ArgumentError] if [tags] is not recursively JSON-compatible.
Object? tagsForWeb(Object? tags) {
  if (tags == null) {
    return null;
  }
  validateTags(tags);
  return tags;
}

/// Throws an [ArgumentError] unless [tags] is recursively JSON-compatible.
///
/// Accepts [String], [num], [bool], null, [List] and [Map] with [String] keys,
/// nested to any depth. Rejects anything else, because it cannot survive the
/// trip to the server: an arbitrary Dart object has no JSON form, a non-string
/// map key has no JSON key, and a non-finite double has no JSON literal.
void validateTags(Object? tags) => _validate(tags, 'tags');

void _validate(Object? value, String path) {
  if (value == null || value is String || value is bool) {
    return;
  }
  // One `num` branch rather than `int` and `double` ones: on the web every
  // number is a double, and `double.infinity is int` is true there because the
  // check is a floor comparison. Split branches would let infinity through.
  if (value is num) {
    if (!value.isFinite) {
      throw ArgumentError.value(
          value, path, 'Tags cannot hold a non-finite number');
    }
    return;
  }
  if (value is List<Object?>) {
    for (var index = 0; index < value.length; index++) {
      _validate(value[index], '$path[$index]');
    }
    return;
  }
  if (value is Map<Object?, Object?>) {
    for (final entry in value.entries) {
      final key = entry.key;
      if (key is! String) {
        throw ArgumentError.value(
            key, path, 'Tag map keys must be strings, got ${key.runtimeType}');
      }
      _validate(entry.value, "$path['$key']");
    }
    return;
  }
  throw ArgumentError.value(value, path,
      'Tags must be JSON-compatible, got ${value.runtimeType}');
}
