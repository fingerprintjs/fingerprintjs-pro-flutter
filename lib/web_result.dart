import 'dart:js_interop';

import 'js_agent_interop.dart';
import 'result.dart';

extension FingerprintJSProResponseWeb on FingerprintJSProResponse {
  /// Creates class instance from JavaScript object
  static FingerprintJSProResponse fromJsObject(IdentificationResult jsObject) {
    return FingerprintJSProResponse(
      jsObject.requestId,
      jsObject.visitorId,
      ConfidenceScore(jsObject.confidence.score),
      jsObject.sealedResult,
    );
  }
}

extension FingerprintJSProExtendedResponseWeb
    on FingerprintJSProExtendedResponse {
  /// Creates class instance from JavaScript object
  static FingerprintJSProExtendedResponse fromJsObject(
      IdentificationExtendedResult jsObject) {
    return FingerprintJSProExtendedResponse(
      jsObject.requestId,
      jsObject.visitorId,
      ConfidenceScore(jsObject.confidence.score),
      jsObject.sealedResult,
      jsObject.visitorFound,
      jsObject.ip,
      IpLocationWeb.fromJsObject(jsObject.ipLocation),
      jsObject.os,
      jsObject.osVersion,
      jsObject.device,
      StSeenAtWeb.fromJsObject(jsObject.firstSeenAt),
      StSeenAtWeb.fromJsObject(jsObject.lastSeenAt),
    );
  }
}

extension IpLocationWeb on IpLocation {
  /// Creates class instance from JavaScript object
  static IpLocation? fromJsObject(IdentificationResultIpLocation? jsObject) {
    if (jsObject == null) {
      return null;
    }
    return IpLocation(
      jsObject.accuracyRadius,
      jsObject.latitude,
      jsObject.longitude,
      jsObject.postalCode,
      jsObject.timezone,
      CityWeb.fromJsObject(jsObject.city),
      CountryWeb.fromJsObject(jsObject.country),
      ContinentWeb.fromJsObject(jsObject.continent),
      jsObject.subdivisions != null
          ? List<Subdivision>.from((jsObject.subdivisions!.toDart)
              .map((subdivision) => SubdivisionWeb.fromJsObject(subdivision)))
          : null,
    );
  }
}

extension CityWeb on City {
  /// Creates class instance from JavaScript object
  static City? fromJsObject(IdentificationResultCity? jsObject) {
    if (jsObject == null) {
      return null;
    }
    return City(jsObject.name);
  }
}

extension CountryWeb on Country {
  /// Creates class instance from JavaScript object
  static Country? fromJsObject(IdentificationResultCountry? jsObject) {
    if (jsObject == null) {
      return null;
    }
    return Country(jsObject.code, jsObject.name);
  }
}

extension ContinentWeb on Continent {
  /// Creates class instance from JavaScript object
  static Continent? fromJsObject(IdentificationResultContinent? jsObject) {
    if (jsObject == null) {
      return null;
    }
    return Continent(jsObject.code, jsObject.name);
  }
}

extension SubdivisionWeb on Subdivision {
  /// Creates class instance from JavaScript object
  static Subdivision? fromJsObject(IdentificationResultSubdivision? jsObject) {
    if (jsObject == null) {
      return null;
    }
    return Subdivision(jsObject.isoCode, jsObject.name);
  }
}

extension StSeenAtWeb on StSeenAt {
  /// Creates class instance from JavaScript object
  static StSeenAt fromJsObject(IdentificationResultStSeenAt jsObject) {
    return StSeenAt(jsObject.global, jsObject.subscription);
  }
}
