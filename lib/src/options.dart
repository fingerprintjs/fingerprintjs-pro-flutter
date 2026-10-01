/// Platform settings for [Fingerprint]. Shared fields stay on the constructor.
///
/// Android, iOS, and web options are separate so a setting cannot silently
/// no-op on a platform that does not support it.
library;

/// Android client settings.
///
/// https://docs.fingerprint.com/docs/android-quickstart
class AndroidOptions {
  /// When true, the SDK may collect location data. It is collected during
  /// each `get`, see [locationTimeout].
  /// https://docs.fingerprint.com/docs/android-sdk
  final bool? allowUseOfLocationData;

  /// How long identification may wait for a location fix. Must be at least
  /// 1 millisecond, checked on every platform.
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
  /// When true, the SDK may collect location data. Collection starts when
  /// the client is created, so create it at app startup and keep it for
  /// better precision.
  /// https://docs.fingerprint.com/docs/ios-sdk#using-location-data-for-proximity-detection
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
/// Either a [WebCachePreset] or a [WebCacheCustomDuration]. The presets are
/// sent by name, so the JS agent decides how long they last.
/// https://docs.fingerprint.com/reference/js-agent-start-function
sealed class WebCacheDuration {
  /// 1 hour.
  static const optimizeCost = WebCachePreset.optimizeCost;

  /// 12 hours.
  static const aggressive = WebCachePreset.aggressive;

  /// See [WebCacheCustomDuration.new].
  factory WebCacheDuration.custom(Duration duration) = WebCacheCustomDuration;
}

/// Named [WebCacheDuration] presets.
enum WebCachePreset implements WebCacheDuration { optimizeCost, aggressive }

/// A [WebCacheDuration] in whole seconds.
final class WebCacheCustomDuration implements WebCacheDuration {
  /// [duration] in whole seconds, greater than zero, at most 12 hours.
  ///
  /// The 12 hour maximum is intentionally not checked here. The JS agent
  /// validates it, so the limit can change without a plugin release.
  /// https://docs.fingerprint.com/reference/js-agent-start-function
  WebCacheCustomDuration(Duration duration) : seconds = duration.inSeconds {
    if (duration <= Duration.zero) {
      throw ArgumentError.value(
        duration,
        'duration',
        'Cache duration must be greater than zero',
      );
    }
    if (duration != Duration(seconds: seconds)) {
      throw ArgumentError.value(
        duration,
        'duration',
        'Cache duration must be a whole number of seconds',
      );
    }
  }

  final int seconds;

  @override
  bool operator ==(Object other) =>
      other is WebCacheCustomDuration && other.seconds == seconds;

  @override
  int get hashCode => seconds.hashCode;
}

/// Web identification result cache. Off when omitted from [WebOptions].
///
/// https://docs.fingerprint.com/reference/js-agent-start-function
class WebCache {
  /// Where the cached result is stored.
  final WebCacheStorage storage;

  /// How long the cached result is reused.
  final WebCacheDuration duration;

  /// Prefix for `sessionStorage` and `localStorage` keys.
  final String? cachePrefix;

  const WebCache({
    required this.storage,
    required this.duration,
    this.cachePrefix,
  });

  @override
  bool operator ==(Object other) =>
      other is WebCache &&
      other.storage == storage &&
      other.duration == duration &&
      other.cachePrefix == cachePrefix;

  @override
  int get hashCode => Object.hash(storage, duration, cachePrefix);
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
