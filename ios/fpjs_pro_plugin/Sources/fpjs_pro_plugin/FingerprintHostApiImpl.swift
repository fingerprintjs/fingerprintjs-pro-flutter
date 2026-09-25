// Pigeon HostApi: identification via iOS Fingerprint SDK 4.x.

@preconcurrency import Fingerprint
import Foundation

// Pigeon completion is not Sendable. Box it so the SDK callback can call it
// under Swift 6.
// https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/#Sendable-Types
private final class CompletionBox: @unchecked Sendable {
  let completion: (Result<FingerprintNativeResult, Error>) -> Void

  init(_ completion: @escaping (Result<FingerprintNativeResult, Error>) -> Void) {
    self.completion = completion
  }
}

/// Pigeon HostApi backed by the iOS Fingerprint SDK 4.x.
final class FingerprintHostApiImpl: FingerprintHostApi {
  private let clientCache: FingerprintClientCache

  init(clientCache: FingerprintClientCache = FingerprintClientCache()) {
    self.clientCache = clientCache
  }

  func create(config: FingerprintNativeConfig) throws {
    _ = nativeClient(for: config)
  }

  func get(
    config: FingerprintNativeConfig,
    tags: [String?: Any?]?,
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
            // Native FingerprintResponse -> Pigeon result.
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
    clientCache.getOrCreate(
      configuration: buildConfiguration(config: config),
      pluginVersion: config.pluginVersion
    )
  }

  private func buildConfiguration(config: FingerprintNativeConfig) -> Configuration {
    let fallbacks = config.endpointFallbacks?.filter { !$0.isEmpty } ?? []
    let namedRegion = Self.namedRegion(config.region)
    let region: Region
    if let endpoint = config.endpoint, !endpoint.isEmpty {
      region = .custom(domain: endpoint, fallback: fallbacks)
    } else if !fallbacks.isEmpty {
      // iOS only attaches fallbacks on Region.custom. With no primary URL, use
      // the region's default endpoint as that custom domain so fallbacks still
      // apply. Android does the same with `endpoint ?: region.endpointUrl`.
      // https://docs.fingerprint.com/docs/ios-sdk
      region = .custom(domain: Self.defaultEndpoint(namedRegion), fallback: fallbacks)
    } else {
      region = namedRegion
    }
    return Configuration(
      apiKey: config.apiKey,
      region: region,
      integrationInfo: [("fingerprint-pro-flutter", config.pluginVersion)],
      allowUseOfLocationData: config.allowUseOfLocationData
    )
  }

  private func prepareMetadata(linkedId: String?, tags: [String?: Any?]?) -> Metadata {
    var metadata = Metadata(linkedId: linkedId)
    guard let tags else {
      return metadata
    }
    for (key, value) in tags {
      guard let key else { continue }
      if let converted = jsonType(from: value) {
        metadata.setTag(converted, forKey: key)
      }
    }
    return metadata
  }

  private static func namedRegion(_ region: String?) -> Region {
    switch region?.lowercased() {
    case "eu":
      return .eu
    case "ap":
      return .ap
    default:
      return .global
    }
  }

  private static func defaultEndpoint(_ region: Region) -> String {
    switch region {
    case .eu:
      return "https://eu.api.fpjs.io"
    case .ap:
      return "https://ap.api.fpjs.io"
    default:
      return "https://api.fpjs.io"
    }
  }
}
