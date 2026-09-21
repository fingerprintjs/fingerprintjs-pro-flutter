/// Validation of the `tags` argument.
///
/// Same string-keyed map on every platform. No size cap here. The server
/// enforces [16 KB](https://docs.fingerprint.com/docs/tagging-information)
/// as `payload_too_large`.
library;

/// Throws an [ArgumentError] unless [tags] is recursively JSON-compatible.
///
/// Root is a string-keyed map. Values may be [String], [num], [bool], null,
/// [List], or nested maps. Rejects non-JSON objects, non-string keys,
/// non-finite numbers, and cycles.
void validateTags(Map<String, Object?>? tags) {
  if (tags != null) {
    _validate(tags, 'tags', []);
  }
}

/// Walks [value]. [enclosing] is the collections currently being visited,
/// outermost first, so a cycle is rejected before the stack overflows.
void _validate(Object? value, String path, List<Object> enclosing) {
  if (value == null || value is String || value is bool) {
    return;
  }
  // On the web, `double.infinity is int` is true. One `num` check so infinity
  // is rejected.
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

/// Rejects [collection] if it is already being walked. Compared by identity,
/// so the same map twice side by side is fine.
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
