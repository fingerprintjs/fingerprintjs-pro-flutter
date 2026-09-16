/// The result of a successful identification request.
///
/// The constructor normalizes what the platforms report inconsistently, so
/// every implementation, Android, iOS and web, produces the same shape.
final class FingerprintResult {
  /// Identifier of this identification event. Different for every request.
  ///
  /// Use it to look the event up in the
  /// [Server API](https://dev.fingerprint.com/reference/getevent).
  final String eventId;

  /// The visitor identifier.
  ///
  /// An empty string when the visitor could not be identified, which happens
  /// with [Zero Trust](https://dev.fingerprint.com/docs/zero-trust-mode)
  /// traffic, and with bots and modified browsers.
  final String visitorId;

  /// How likely it is that the request came from a bad actor, from 0 to 100.
  ///
  /// Null when the platform did not report one. See
  /// [Suspect Score](https://dev.fingerprint.com/docs/suspect-score).
  final int? suspectScore;

  /// The encrypted `/events` Server API response for this event, base64-encoded.
  ///
  /// Null unless [Sealed Results](https://dev.fingerprint.com/docs/sealed-client-results)
  /// are enabled and available.
  final String? sealedResult;

  /// Whether the result came from the agent's cache instead of the server.
  ///
  /// Always null outside the web, which is the only platform that caches.
  final bool? cacheHit;

  /// Creates a result, normalizing the values the platforms disagree on.
  ///
  /// A null [visitorId] becomes an empty string, and an empty [sealedResult]
  /// becomes null: Android and iOS send an empty string where the web agent
  /// omits the field, and neither absence should surface as two different
  /// values.
  FingerprintResult({
    required this.eventId,
    required String? visitorId,
    this.suspectScore,
    String? sealedResult,
    this.cacheHit,
  })  : visitorId = visitorId ?? '',
        sealedResult =
            (sealedResult == null || sealedResult.isEmpty) ? null : sealedResult;

  @override
  String toString() => 'FingerprintResult(eventId: $eventId, '
      'visitorId: $visitorId, suspectScore: $suspectScore, '
      'sealedResult: $sealedResult, cacheHit: $cacheHit)';

  @override
  bool operator ==(Object other) =>
      other is FingerprintResult &&
      other.eventId == eventId &&
      other.visitorId == visitorId &&
      other.suspectScore == suspectScore &&
      other.sealedResult == sealedResult &&
      other.cacheHit == cacheHit;

  @override
  int get hashCode =>
      Object.hash(eventId, visitorId, suspectScore, sealedResult, cacheHit);
}
