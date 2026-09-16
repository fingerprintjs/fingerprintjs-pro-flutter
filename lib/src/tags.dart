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
/// map key has no JSON key, a non-finite double has no JSON literal, and a
/// collection that contains itself has no end.
void validateTags(Object? tags) => _validate(tags, 'tags', []);

/// Validates [value], with [enclosing] holding the collections currently being
/// walked, outermost first, so a collection that contains itself is rejected
/// rather than followed until the stack runs out.
void _validate(Object? value, String path, List<Object> enclosing) {
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
    _checkNotEnclosing(value, path, enclosing);
    enclosing.add(value);
    for (var index = 0; index < value.length; index++) {
      _validate(value[index], '$path[$index]', enclosing);
    }
    enclosing.removeLast();
    return;
  }
  if (value is Map<Object?, Object?>) {
    _checkNotEnclosing(value, path, enclosing);
    enclosing.add(value);
    for (final entry in value.entries) {
      final key = entry.key;
      if (key is! String) {
        throw ArgumentError.value(
            key, path, 'Tag map keys must be strings, got ${key.runtimeType}');
      }
      _validate(entry.value, "$path['$key']", enclosing);
    }
    enclosing.removeLast();
    return;
  }
  throw ArgumentError.value(value, path,
      'Tags must be JSON-compatible, got ${value.runtimeType}');
}

/// Throws an [ArgumentError] if [collection] is one of the collections already
/// being walked, which means the tags contain a cycle.
///
/// Compared by identity, so the same collection appearing twice side by side is
/// still fine. Only a collection reachable from itself is a cycle.
void _checkNotEnclosing(
    Object collection, String path, List<Object> enclosing) {
  for (final walked in enclosing) {
    if (identical(walked, collection)) {
      throw ArgumentError.value(
          collection, path, 'Tags cannot contain themselves');
    }
  }
}
