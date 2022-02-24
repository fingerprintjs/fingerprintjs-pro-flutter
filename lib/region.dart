enum Region { eu, us }

Region parseRegion(String value) {
  final str = value.toLowerCase();

  switch (str) {
    case 'eu':
      return Region.eu;
    default:
      return Region.us;
  }
}

extension RegionValue on Region {
  String get stringValue => toString().split('.')[1].toLowerCase();
}