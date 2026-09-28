import 'package:flutter/services.dart';
import 'package:fpjs_pro_plugin/src/fingerprint_error.dart';

/// Builds a [FingerprintError] from any error a Pigeon call throws.
///
/// - Native adapters already send snake_case codes. [PlatformException.details]
///   is the event id when the client reported one.
/// - Other errors (e.g. a missing Flutter binding) become [FingerprintError.unknownError], so
///   `get` only ever throws [FingerprintError].
FingerprintError unwrapError(Object error) {
  if (error is! PlatformException) {
    return FingerprintError(
      code: FingerprintError.unknownError,
      message: error.toString(),
    );
  }
  final details = error.details;
  return FingerprintError(
    code: error.code,
    message: error.message,
    eventId: details is String ? details : null,
  );
}
