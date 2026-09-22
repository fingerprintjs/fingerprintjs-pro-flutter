import 'package:flutter/services.dart';
import 'package:fpjs_pro_plugin/src/fingerprint_error.dart';

/// Builds a [FingerprintError] from a Pigeon [PlatformException].
///
/// Native adapters already send snake_case codes. [PlatformException.details]
/// is the event id when the client reported one.
FingerprintError unwrapError(PlatformException error) {
  final details = error.details;
  return FingerprintError(
    code: error.code,
    message: error.message,
    eventId: details is String ? details : null,
  );
}
