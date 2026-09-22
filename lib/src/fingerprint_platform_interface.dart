import 'package:fpjs_pro_plugin/region.dart';
import 'package:fpjs_pro_plugin/result.dart';
import 'package:fpjs_pro_plugin/src/fingerprint_native.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Configuration of the Fingerprint Pro client, passed to [FingerprintPlatform.init]
class FingerprintConfig {
  final String apiKey;
  final String pluginVersion;
  final String? endpoint;
  final List<String>? endpointFallbacks;
  final String? scriptUrlPattern;
  final List<String>? scriptUrlPatternFallbacks;
  final Region? region;
  final bool? allowUseOfLocationData;
  final int? locationTimeoutMillisAndroid;
  final bool extendedResponseFormat;

  const FingerprintConfig({
    required this.apiKey,
    required this.pluginVersion,
    this.endpoint,
    this.endpointFallbacks,
    this.scriptUrlPattern,
    this.scriptUrlPatternFallbacks,
    this.region,
    this.allowUseOfLocationData,
    this.locationTimeoutMillisAndroid,
    this.extendedResponseFormat = false,
  });
}

/// The interface each platform implementation of this plugin implements
abstract class FingerprintPlatform extends PlatformInterface {
  FingerprintPlatform() : super(token: _token);

  static final Object _token = Object();

  static FingerprintPlatform _instance = FingerprintNative();

  /// The implementation used by [FpjsProPlugin], [FingerprintNative] by default
  static FingerprintPlatform get instance => _instance;

  static set instance(FingerprintPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Initializes the Fingerprint Pro client
  Future<void> init(FingerprintConfig config);

  /// Returns the visitor identifier
  /// Throws a [FingerprintProError] if the identification request fails
  Future<String?> getVisitorId({
    Map<String, dynamic>? tags,
    String? linkedId,
    int? timeoutMs,
  });

  /// Returns the full identification result
  /// Throws a [FingerprintProError] if the identification request fails
  Future<FingerprintJSProResponse> getVisitorData({
    Map<String, dynamic>? tags,
    String? linkedId,
    int? timeoutMs,
  });
}
