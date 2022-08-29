import 'dart:convert';

class FingerprintJSProResponse {
  final String requestId;
  final String visitorId;
  final ConfidenceScore confidenceScore;
  final String? errorMessage;

  FingerprintJSProResponse.fromJson(
      Map<String, dynamic> json, this.requestId, num confidence)
      : visitorId = json['visitorId'],
        confidenceScore = ConfidenceScore(confidence),
        errorMessage = json['errorMessage'];

  Map toJson() {
    Map fromObject = {
      "requestId": requestId,
      "visitorId": visitorId,
      "confidenceScore": confidenceScore.toJson(),
      "errorMessage": errorMessage
    };

    return fromObject;
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

class FingerprintJSProExtendedResponse extends FingerprintJSProResponse {
  final bool visitorFound;
  final String ipAddress;
  final IpLocation? ipLocation;
  final String osName;
  final String osVersion;
  final String device;
  final StSeenAt firstSeenAt;
  final StSeenAt lastSeenAt;

  FingerprintJSProExtendedResponse.fromJson(
      Map<String, dynamic> json, String requestId, num confidence)
      : visitorFound = json['visitorFound'],
        ipAddress = json['ip'],
        ipLocation = IpLocation.fromJson(json['ipLocation']),
        osName = json['os'],
        osVersion = json['osVersion'],
        device = json['device'],
        firstSeenAt = StSeenAt.fromJson(json['firstSeenAt']),
        lastSeenAt = StSeenAt.fromJson(json['lastSeenAt']),
        super.fromJson(json, requestId, confidence);

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

class ConfidenceScore {
  final num score;

  ConfidenceScore(this.score);

  Map toJson() {
    Map fromObject = {
      "score": score,
    };

    return fromObject;
  }
}

class IpLocation {
  final num accuracyRadius;
  final num latitude;
  final num longitude;
  final String postalCode;
  final String timezone;
  final City city;
  final Country country;
  final Continent continent;
  final List<Subdivision> subdivisions;

  IpLocation.fromJson(Map<String, dynamic> json)
      : accuracyRadius = json['accuracyRadius'],
        latitude = json['latitude'],
        longitude = json['longitude'],
        postalCode = json['postalCode'],
        timezone = json['timezone'],
        city = City.fromJson(json['city']),
        country = Country.fromJson(json['country']),
        continent = Continent.fromJson(json['continent']),
        subdivisions = List<Subdivision>.from((json['subdivisions'] as List)
            .map((subdivision) => Subdivision.fromJson(subdivision)));

  Map toJson() {
    Map fromObject = {
      "accuracyRadius": accuracyRadius,
      "latitude": latitude,
      "longitude": longitude,
      "postalCode": postalCode,
      "timezone": timezone,
      "city": city.toJson(),
      "country": country.toJson(),
      "continent": continent.toJson(),
      "subdivisions":
          subdivisions.map((subdivision) => subdivision.toJson()).toList(),
    };

    return fromObject;
  }
}

class City {
  final String name;

  City.fromJson(Map<String, dynamic> json) : name = json['name'];

  Map toJson() {
    Map fromObject = {
      "name": name,
    };

    return fromObject;
  }
}

class Country {
  final String code;
  final String name;

  Country.fromJson(Map<String, dynamic> json)
      : code = json['code'],
        name = json['name'];

  Map toJson() {
    Map fromObject = {
      "code": code,
      "name": name,
    };

    return fromObject;
  }
}

class Continent {
  final String code;
  final String name;

  Continent.fromJson(Map<String, dynamic> json)
      : code = json['code'],
        name = json['name'];

  Map toJson() {
    Map fromObject = {
      "code": code,
      "name": name,
    };

    return fromObject;
  }
}

class Subdivision {
  final String isoCode;
  final String name;

  Subdivision.fromJson(Map<String, dynamic> json)
      : isoCode = json['isoCode'],
        name = json['name'];

  Map toJson() {
    Map fromObject = {
      "isoCode": isoCode,
      "name": name,
    };

    return fromObject;
  }
}

class StSeenAt {
  final String? global;
  final String? subscription;

  StSeenAt.fromJson(Map<String, dynamic> json)
      : global = json['global'],
        subscription = json['subscription'];

  Map toJson() {
    Map fromObject = {
      "global": global,
      "subscription": subscription,
    };

    return fromObject;
  }
}