import Foundation
@preconcurrency import Fingerprint

private final class CompletionBox: @unchecked Sendable {
  let completion: (Result<FingerprintNativeResult, Error>) -> Void

  init(_ completion: @escaping (Result<FingerprintNativeResult, Error>) -> Void) {
    self.completion = completion
  }
}

/// Pigeon HostApi backed by the iOS Fingerprint SDK 4.x.
final class FingerprintHostApiImpl: FingerprintHostApi {
  private let clientCache = FingerprintClientCache()

  func create(config: FingerprintNativeConfig) throws {
    _ = nativeClient(for: config)
  }

  func get(
    config: FingerprintNativeConfig,
    tags: [AnyHashable?: Any?]?,
    linkedId: String?,
    timeoutMs: Int64?,
    completion: @escaping (Result<FingerprintNativeResult, Error>) -> Void
  ) {
    let client = nativeClient(for: config)
    let metadata = prepareMetadata(linkedId: linkedId, tags: tags)
    let timeoutSeconds: TimeInterval? = timeoutMs.map { TimeInterval($0) / 1000.0 }
    let box = CompletionBox(completion)

    let handler: VisitorIdResponseBlock = { result in
      switch result {
      case .success(let response):
        box.completion(
          .success(
            FingerprintNativeResult(
              eventId: response.eventId,
              visitorId: response.visitorId,
              suspectScore: response.suspectScore.map { Int64($0) },
              sealedResult: response.sealedResult
            )
          )
        )
      case .failure(let error):
        let fields = error.pigeonFields()
        box.completion(
          .failure(PigeonError(code: fields.code, message: fields.message, details: fields.eventId))
        )
      }
    }

    if let timeoutSeconds {
      client.getVisitorIdResponse(metadata, timeout: timeoutSeconds, completion: handler)
    } else {
      client.getVisitorIdResponse(metadata, completion: handler)
    }
  }

  private func nativeClient(for config: FingerprintNativeConfig) -> FingerprintClientProviding {
    let (configuration, cacheKey) = buildConfiguration(config: config)
    return clientCache.getOrCreate(configuration: configuration, cacheKey: cacheKey)
  }

  private func buildConfiguration(config: FingerprintNativeConfig) -> (Configuration, String) {
    let endpoints = config.endpoints?.filter { !$0.isEmpty } ?? []
    let region: Region
    let regionToken: String
    if !endpoints.isEmpty {
      let fallback = endpoints.count > 1 ? Array(endpoints.dropFirst()) : []
      region = .custom(domain: endpoints[0], fallback: fallback)
      regionToken = "custom:\(endpoints.joined(separator: ","))"
    } else {
      switch config.region?.lowercased() {
      case "eu":
        region = .eu
        regionToken = "eu"
      case "ap":
        region = .ap
        regionToken = "ap"
      default:
        region = .global
        regionToken = "global"
      }
    }
    let configuration = Configuration(
      apiKey: config.apiKey,
      region: region,
      integrationInfo: [("fingerprint-pro-flutter", config.pluginVersion)],
      allowUseOfLocationData: config.allowUseOfLocationData
    )
    let endpointsToken = endpoints.joined(separator: "\u{0001}")
    let cacheKey = fingerprintCacheKey(
      apiKey: config.apiKey,
      regionToken: regionToken,
      endpointsToken: endpointsToken,
      pluginVersion: config.pluginVersion,
      allowUseOfLocationData: config.allowUseOfLocationData
    )
    return (configuration, cacheKey)
  }

  private func prepareMetadata(linkedId: String?, tags: [AnyHashable?: Any?]?) -> Metadata {
    var metadata = Metadata(linkedId: linkedId)
    guard let tags else {
      return metadata
    }
    var dict: [String: Any] = [:]
    for (key, value) in tags {
      guard let key = key as? String, let value else { continue }
      dict[key] = value
    }
    let jsonTags = JSONTypeConvertor.convertDictionaryToJSONTypeConvertible(dict)
    jsonTags.forEach { key, jsonType in
      metadata.setTag(jsonType, forKey: key)
    }
    return metadata
  }
}
