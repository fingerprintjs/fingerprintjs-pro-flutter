/// Region in which FingerprintJS Pro subscription is created
enum Region { eu, us }

/// Returns a string value of a region to pass to the native library through a [MethodChannel]
extension RegionValue on Region {
  String get stringValue => toString().split('.')[1].toLowerCase();
}
