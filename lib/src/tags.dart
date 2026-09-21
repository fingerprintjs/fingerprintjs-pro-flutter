/// Validation of the `tags` argument.
///
/// Tags use the same string-keyed map on every platform. Android and iOS
/// require that shape, and the web agent accepts it. See the Android v4
/// [interface](https://github.com/fingerprintjs/fingerprintjs-pro-android-private/blob/f6b574089e8dfb98747a0901bfe506b67b49c6a2/fpjs-pro/src/main/java/com/fingerprint/android/Fingerprint.kt#L63-L89)
/// and iOS v4 [metadata](https://github.com/fingerprintjs/fingerprintjs-pro-ios-private/blob/0dae3509bc38080d2c57ad295a3cbb6962b21273/Sources/FingerprintPro/Library/Metadata.swift#L1-L25).
///
/// There is no size cap here. The
/// [16 KB limit](https://docs.fingerprint.com/docs/tagging-information) is a
/// server-side product limit reported as `payload_too_large`.
library;

/// Throws an [ArgumentError] unless [tags] is recursively JSON-compatible.
///
/// The root is a map with [String] keys. Its values can contain [String], [num],
/// [bool], null, [List] and nested maps. Rejects anything else, because it
/// cannot survive the trip to the server: an arbitrary Dart object has no JSON
/// form, a non-string nested map key has no JSON key, a non-finite double has no
/// JSON literal, and a collection that contains itself has no end.
void validateTags(Map<String, Object?>? tags) {
  if (tags != null) {
    _validate(tags, 'tags', []);
  }
}

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
        value,
        path,
        'Tags cannot hold a non-finite number',
      );
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
          key,
          path,
          'Tag map keys must be strings, got ${key.runtimeType}',
        );
      }
      _validate(entry.value, "$path['$key']", enclosing);
    }
    enclosing.removeLast();
    return;
  }
  throw ArgumentError.value(
    value,
    path,
    'Tags must be JSON-compatible, got ${value.runtimeType}',
  );
}

/// Throws an [ArgumentError] if [collection] is one of the collections already
/// being walked, which means the tags contain a cycle.
///
/// Compared by identity, so the same collection appearing twice side by side is
/// still fine. Only a collection reachable from itself is a cycle.
void _checkNotEnclosing(
  Object collection,
  String path,
  List<Object> enclosing,
) {
  for (final walked in enclosing) {
    if (identical(walked, collection)) {
      throw ArgumentError.value(
        collection,
        path,
        'Tags cannot contain themselves',
      );
    }
  }
}
