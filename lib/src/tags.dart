/// Validation of the `tags` argument.
///
/// Same string-keyed JSON map on every platform. Checked in Dart so a bad
/// value throws [ArgumentError] everywhere. Native code would otherwise
/// crash on one OS and drop the value on another.
///
/// No size cap here. The server enforces
/// [16 KB](https://docs.fingerprint.com/docs/tagging-information) as
/// `payload_too_large`.
library;

/// Throws an [ArgumentError] unless [tags] is recursively JSON-compatible.
///
/// Root is a string-keyed map. Values may be [String], [num], [bool], null,
/// [List], or nested maps. Rejects non-JSON objects, non-string keys, and
/// non-finite numbers.
void validateTags(Map<String, Object?>? tags) {
  if (tags != null) {
    _validate(tags, 'tags');
  }
}

void _validate(Object? value, String path) {
  if (value == null || value is String || value is bool) {
    return;
  }
  // On the web, `double.infinity is int` is true. Check `num` first so
  // infinity is rejected instead of treated as an integer.
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
  if (value is List) {
    for (var index = 0; index < value.length; index++) {
      _validate(value[index], '$path[$index]');
    }
    return;
  }
  if (value is Map) {
    for (final entry in value.entries) {
      final key = entry.key;
      if (key is! String) {
        throw ArgumentError.value(
          key,
          path,
          'Tag map keys must be strings, got ${key.runtimeType}',
        );
      }
      _validate(entry.value, "$path['$key']");
    }
    return;
  }
  throw ArgumentError.value(
    value,
    path,
    'Tags must be JSON-compatible, got ${value.runtimeType}',
  );
}
