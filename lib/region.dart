/// Fingerprint workspace region.
enum Region { eu, us, ap }

/// Lowercase region name sent to the native SDKs and the JS agent.
extension RegionValue on Region {
  String get stringValue => toString().split('.')[1].toLowerCase();
}
