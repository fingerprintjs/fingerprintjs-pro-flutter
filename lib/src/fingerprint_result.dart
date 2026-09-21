/// The result of a successful identification request.
///
/// The constructor normalizes values the platforms report differently.
final class FingerprintResult {
  /// Identifier of this identification event. Different for every request.
  ///
  /// Look it up in the [Server API](https://dev.fingerprint.com/reference/getevent).
  final String eventId;

  /// The visitor identifier.
  ///
  /// Empty when the visitor could not be identified. See
  /// [Zero Trust](https://dev.fingerprint.com/docs/zero-trust-mode).
  final String visitorId;

  /// How likely the request came from a bad actor, 0 to 100.
  ///
  /// Null when the platform did not report one. See
  /// [Suspect Score](https://dev.fingerprint.com/docs/suspect-score).
  final int? suspectScore;

  /// Encrypted `/events` response for this event, base64-encoded.
  ///
  /// Null unless [Sealed Results](https://dev.fingerprint.com/docs/sealed-client-results)
  /// are enabled and available.
  final String? sealedResult;

  /// Whether the result came from the agent's cache.
  ///
  /// Null outside the web. Only the web agent caches.
  final bool? cacheHit;

  /// Creates a result.
  ///
  /// A null [visitorId] becomes `''`. An empty [sealedResult] becomes null
  /// (native sends `''` where web omits the field).
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
