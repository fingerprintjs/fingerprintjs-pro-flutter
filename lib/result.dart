import 'dart:convert';

/// Result of getting a visitor id.
///
/// `visitorId` can be empty string when the visitor can't be identified.
/// It happens only with bots and hackers that modify their browsers.
class FingerprintJSProResponse {
  /// The current request identifier. It's different for every request.
  final String requestId;

  /// The visitor identifier
  final String visitorId;

  /// A confidence score that tells how much the agent is sure about the visitor identifier
  final ConfidenceScore confidenceScore;

  /// Creates class instance from JSON Object
  /// that can be returned by Android or iOS agent, or can be a serialization result
  FingerprintJSProResponse.fromJson(
      Map<String, dynamic> json, this.requestId, num confidence)
      : visitorId = json['visitorId'],
        confidenceScore = ConfidenceScore(confidence);

  /// Creates class instance from JavaScript object
  FingerprintJSProResponse.fromJsObject(dynamic jsObject)
      : visitorId = jsObject.visitorId,
        requestId = jsObject.requestId,
        confidenceScore = ConfidenceScore(jsObject.confidence.score);

  /// Serialize instance to JSON Object
  Map toJson() {
    Map fromObject = {
      "requestId": requestId,
      "visitorId": visitorId,
      "confidenceScore": confidenceScore.toJson()
    };

    return fromObject;
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

/// Result of requesting a visitor id when requested with `extendedResponseFormat: true`
class FingerprintJSProExtendedResponse extends FingerprintJSProResponse {
  /// If true, this visitor was found and visited before.
  /// If false, this visitor wasn't found and probably didn't visit before.
  /// Because of iOS and Android agents we have this field in Flutter SDK only for extended result
  final bool visitorFound;

  /// IP address. IPv4 or IPv6.
  final String ipAddress;

  /// IP address location. Can be empty for anonymous proxies
  final IpLocation? ipLocation;

  /// OS name
  final String osName;

  /// OS version
  final String osVersion;

  /// Device.
  /// For desktop/laptop devices, the value will be "Other"
  final String device;

  /// When the visitor was seen for the first time
  final StSeenAt firstSeenAt;

  /// When the visitor was seen previous time
  final StSeenAt lastSeenAt;

  /// Creates class instance from JSON Object
  /// that can be returned by Android or iOS agent, or can be a serialization result
  FingerprintJSProExtendedResponse.fromJson(
      super.json, super.requestId, super.confidence)
      : visitorFound = json['visitorFound'],
        ipAddress = json['ip'] ?? json['ipAddress'],
        ipLocation = json['ipLocation'] != null
            ? IpLocation.fromJson(Map<String, dynamic>.from(json['ipLocation']))
            : null,
        osName = json['os'] ?? json['osName'],
        osVersion = json['osVersion'],
        device = json['device'],
        firstSeenAt =
            StSeenAt.fromJson(Map<String, dynamic>.from(json['firstSeenAt'])),
        lastSeenAt =
            StSeenAt.fromJson(Map<String, dynamic>.from(json['lastSeenAt'])),
        super.fromJson();

  /// Creates class instance from JavaScript object
  FingerprintJSProExtendedResponse.fromJsObject(super.jsObject)
      : visitorFound = jsObject.visitorFound,
        ipAddress = jsObject.ip,
        ipLocation = IpLocation.fromJsObject(jsObject.ipLocation),
        osName = jsObject.os,
        osVersion = jsObject.osVersion,
        device = jsObject.device,
        firstSeenAt = StSeenAt.fromJsObject(jsObject.firstSeenAt),
        lastSeenAt = StSeenAt.fromJsObject(jsObject.lastSeenAt),
        super.fromJsObject();

  /// Serialize instance to JSON Object
  @override
  Map toJson() {
    var fromObject = super.toJson();
    fromObject.addAll({
      "visitorFound": visitorFound,
      "ipAddress": ipAddress,
      "ipLocation": ipLocation?.toJson(),
      "osName": osName,
      "osVersion": osVersion,
      "device": device,
      "firstSeenAt": firstSeenAt.toJson(),
      "lastSeenAt": lastSeenAt.toJson(),
    });

    return fromObject;
  }
}

/// A confidence score that tells how much the agent is sure about the visitor identifier
class ConfidenceScore {
  /// A number between 0 and 1 that tells how much the agent is sure about the visitor identifier.
  /// The higher the number, the higher the chance of the visitor identifier to be true.
  final num score;

  ConfidenceScore(this.score);

  /// Serialize instance to JSON Object
  Map toJson() {
    Map fromObject = {
      "score": score,
    };

    return fromObject;
  }
}

/// IP address location. Can be empty for anonymous proxies.
class IpLocation {
  /// IP address location detection radius. Smaller values (<50mi) are business/residential,
  /// medium values (50 < x < 500) are cellular towers (usually),
  /// larger values (>= 500) are cloud IPs or proxies, VPNs.
  /// Can be missing, in case of Tor/proxies.
  final num? accuracyRadius;

  /// Latitude
  /// Can be missing, in case of Tor/proxies.
  final num? latitude;

  /// Longitude
  /// Can be missing, in case of Tor/proxies.
  final num? longitude;

  /// Postal code, when available
  final String? postalCode;

  /// Timezone of the IP address location
  final String? timezone;

  /// City, when available
  final City? city;

  /// Country, when available. Will be missing for Tor/anonymous proxies.
  final Country? country;

  /// Continent, when available. Will be missing for Tor/anonymous proxies.
  final Continent? continent;

  /// Administrative subdivisions array (for example states|provinces -> counties|parishes).
  /// Can be empty or missing.
  /// When not empty, can contain only top-level administrative units within a country, e.g. a state.
  final List<Subdivision>? subdivisions;

  /// Creates class instance from JSON Object
  /// that can be returned by Android or iOS agent, or can be a serialization result
  IpLocation.fromJson(Map<String, dynamic> json)
      : accuracyRadius = json['accuracyRadius'],
        latitude = json['latitude'],
        longitude = json['longitude'],
        postalCode = json['postalCode'],
        timezone = json['timezone'],
        city = json['city'] != null
            ? City.fromJson(Map<String, dynamic>.from(json['city']))
            : null,
        country = json['country'] != null
            ? Country.fromJson(Map<String, dynamic>.from(json['country']))
            : null,
        continent = json['continent'] != null
            ? Continent.fromJson(Map<String, dynamic>.from(json['continent']))
            : null,
        subdivisions = json['subdivisions'] != null
            ? List<Subdivision>.from((json['subdivisions'] as List).map(
                (subdivision) => Subdivision.fromJson(
                    Map<String, dynamic>.from(subdivision))))
            : null;

  /// Creates class instance from JavaScript object
  IpLocation.fromJsObject(dynamic jsObject)
      : accuracyRadius = jsObject.accuracyRadius,
        latitude = jsObject.latitude,
        longitude = jsObject.longitude,
        postalCode = jsObject.postalCode,
        timezone = jsObject.timezone,
        city = City.fromJsObject(jsObject.city),
        country = Country.fromJsObject(jsObject.country),
        continent = Continent.fromJsObject(jsObject.continent),
        subdivisions = List<Subdivision>.from((jsObject.subdivisions as List)
            .map((subdivision) => Subdivision.fromJsObject(subdivision)));

  /// Serialize instance to JSON Object
  Map toJson() {
    Map fromObject = {
      "accuracyRadius": accuracyRadius,
      "latitude": latitude,
      "longitude": longitude,
      "postalCode": postalCode,
      "timezone": timezone,
      "city": city?.toJson(),
      "country": country?.toJson(),
      "continent": continent?.toJson(),
      "subdivisions":
          subdivisions?.map((subdivision) => subdivision.toJson()).toList(),
    };

    fromObject.removeWhere((key, value) => value == null);

    return fromObject;
  }
}

/// City, when available
class City {
  final String name;

  /// Creates class instance from JSON Object
  /// that can be returned by Android or iOS agent, or can be a serialization result
  City.fromJson(Map<String, dynamic> json) : name = json['name'];

  /// Creates class instance from JavaScript object
  City.fromJsObject(dynamic jsObject) : name = jsObject.name;

  /// Serialize instance to JSON Object
  Map toJson() {
    Map fromObject = {
      "name": name,
    };

    return fromObject;
  }
}

/// Country, when available. Will be missing for Tor/anonymous proxies.
class Country {
  final String code;
  final String name;

  /// Creates class instance from JSON Object
  /// that can be returned by Android or iOS agent, or can be a serialization result
  Country.fromJson(Map<String, dynamic> json)
      : code = json['code'],
        name = json['name'];

  /// Creates class instance from JavaScript object
  Country.fromJsObject(dynamic jsObject)
      : code = jsObject.code,
        name = jsObject.name;

  /// Serialize instance to JSON Object
  Map toJson() {
    Map fromObject = {
      "code": code,
      "name": name,
    };

    return fromObject;
  }
}

/// Continent, when available. Will be missing for Tor/anonymous proxies.
class Continent {
  final String code;
  final String name;

  /// Creates class instance from JSON Object
  /// that can be returned by Android or iOS agent, or can be a serialization result
  Continent.fromJson(Map<String, dynamic> json)
      : code = json['code'],
        name = json['name'];

  /// Creates class instance from JavaScript object
  Continent.fromJsObject(dynamic jsObject)
      : code = jsObject.code,
        name = jsObject.name;

  /// Serialize instance to JSON Object
  Map toJson() {
    Map fromObject = {
      "code": code,
      "name": name,
    };

    return fromObject;
  }
}

/// Administrative subdivision (for example states|provinces -> counties|parishes).
/// Can contain only top-level administrative units within a country, e.g. a state.
class Subdivision {
  final String isoCode;
  final String name;

  /// Creates class instance from JSON Object
  /// that can be returned by Android or iOS agent, or can be a serialization result
  Subdivision.fromJson(Map<String, dynamic> json)
      : isoCode = json['isoCode'],
        name = json['name'];

  /// Creates class instance from JavaScript object
  Subdivision.fromJsObject(dynamic jsObject)
      : isoCode = jsObject.isoCode,
        name = jsObject.name;

  /// Serialize instance to JSON Object
  Map toJson() {
    Map fromObject = {
      "isoCode": isoCode,
      "name": name,
    };

    return fromObject;
  }
}

/// When the visitor was seen
class StSeenAt {
  final String? global;
  final String? subscription;

  /// Creates class instance from JSON Object
  /// that can be returned by Android or iOS agent, or can be a serialization result
  StSeenAt.fromJson(Map<String, dynamic> json)
      : global = json['global'],
        subscription = json['subscription'];

  /// Creates class instance from JavaScript object
  StSeenAt.fromJsObject(dynamic jsObject)
      : global = jsObject.global,
        subscription = jsObject.subscription;

  /// Serialize instance to JSON Object
  Map toJson() {
    Map fromObject = {
      "global": global,
      "subscription": subscription,
    };

    return fromObject;
  }
}
