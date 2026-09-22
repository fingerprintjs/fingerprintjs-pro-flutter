/// Platform settings for [Fingerprint]. Shared fields stay on the constructor.
///
/// Android, iOS, and web options are separate so a setting cannot silently
/// no-op on a platform that does not support it.
library;

/// Android client settings.
///
/// https://docs.fingerprint.com/docs/android-quickstart
class AndroidOptions {
  /// When true, the SDK may collect location data.
  final bool? allowUseOfLocationData;

  /// How long identification may wait for a location fix.
  ///
  /// The Android SDK default is 5 seconds when this is omitted.
  final Duration? locationTimeout;

  const AndroidOptions({this.allowUseOfLocationData, this.locationTimeout});

  @override
  bool operator ==(Object other) =>
      other is AndroidOptions &&
      other.allowUseOfLocationData == allowUseOfLocationData &&
      other.locationTimeout == locationTimeout;

  @override
  int get hashCode => Object.hash(allowUseOfLocationData, locationTimeout);
}

/// iOS client settings.
///
/// https://docs.fingerprint.com/docs/ios-sdk
class IosOptions {
  /// When true, the SDK may collect location data.
  final bool? allowUseOfLocationData;

  const IosOptions({this.allowUseOfLocationData});

  @override
  bool operator ==(Object other) =>
      other is IosOptions &&
      other.allowUseOfLocationData == allowUseOfLocationData;

  @override
  int get hashCode => allowUseOfLocationData.hashCode;
}

/// Which parts of the page URL the web agent hashes before sending.
///
/// https://docs.fingerprint.com/reference/js-agent-start-function
class WebUrlHashing {
  /// Hash the path (between the origin and `?`).
  final bool? path;

  /// Hash the query (between `?` and `#`).
  final bool? query;

  /// Hash the fragment (after `#`).
  final bool? fragment;

  const WebUrlHashing({this.path, this.query, this.fragment});

  @override
  bool operator ==(Object other) =>
      other is WebUrlHashing &&
      other.path == path &&
      other.query == query &&
      other.fragment == fragment;

  @override
  int get hashCode => Object.hash(path, query, fragment);
}

/// Where the web agent stores a cached identification result.
enum WebCacheStorage { sessionStorage, localStorage, agent }

/// How long a cached web identification result is reused.
///
/// [optimizeCost] is 1 hour. [aggressive] is 12 hours. A [custom] duration
/// cannot exceed 12 hours.
/// https://docs.fingerprint.com/reference/js-agent-start-function
class WebCacheDuration {
  // Distinct const args so Dart does not canonicalize the presets together.
  const WebCacheDuration._(this._kind, {this.seconds});

  static const optimizeCost = WebCacheDuration._(_Kind.optimizeCost);
  static const aggressive = WebCacheDuration._(_Kind.aggressive);

  /// [duration] in whole seconds. Must be greater than zero and at most 12 hours.
  factory WebCacheDuration.custom(Duration duration) {
    if (duration <= Duration.zero || duration > _max) {
      throw ArgumentError.value(
        duration,
        'duration',
        'Cache duration must be greater than zero and at most 12 hours',
      );
    }
    if (duration != Duration(seconds: duration.inSeconds)) {
      throw ArgumentError.value(
        duration,
        'duration',
        'Cache duration must be a whole number of seconds',
      );
    }
    return WebCacheDuration._(_Kind.custom, seconds: duration.inSeconds);
  }

  static const _max = Duration(hours: 12);

  final _Kind _kind;

  /// Seconds for a custom duration. Null for [optimizeCost] and [aggressive].
  final int? seconds;

  @override
  bool operator ==(Object other) =>
      other is WebCacheDuration &&
      other._kind == _kind &&
      other.seconds == seconds;

  @override
  int get hashCode => Object.hash(_kind, seconds);
}

enum _Kind { optimizeCost, aggressive, custom }

/// Web identification result cache. Off when omitted from [WebOptions].
///
/// https://docs.fingerprint.com/reference/js-agent-start-function
class WebCache {
  /// Where the cached result is stored.
  final WebCacheStorage storage;

  /// How long the cached result is reused.
  final WebCacheDuration duration;

  /// Prefix for `sessionStorage` and `localStorage` keys.
  final String? keyPrefix;

  const WebCache({
    required this.storage,
    required this.duration,
    this.keyPrefix,
  });

  @override
  bool operator ==(Object other) =>
      other is WebCache &&
      other.storage == storage &&
      other.duration == duration &&
      other.keyPrefix == keyPrefix;

  @override
  int get hashCode => Object.hash(storage, duration, keyPrefix);
}

/// Web agent settings.
///
/// https://docs.fingerprint.com/reference/js-agent-start-function
class WebOptions {
  /// Hash URL parts before they are sent.
  final WebUrlHashing? urlHashing;

  /// Prefix for cookies and storage keys. Default is `_vid_`.
  final String? storageKeyPrefix;

  /// Identification result cache. Off when omitted.
  final WebCache? cache;

  const WebOptions({this.urlHashing, this.storageKeyPrefix, this.cache});

  @override
  bool operator ==(Object other) =>
      other is WebOptions &&
      other.urlHashing == urlHashing &&
      other.storageKeyPrefix == storageKeyPrefix &&
      other.cache == cache;

  @override
  int get hashCode => Object.hash(urlHashing, storageKeyPrefix, cache);
}
