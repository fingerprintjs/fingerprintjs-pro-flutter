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
  // One client per config. Pigeon generates Hashable for the config.
  // Configs that differ only in a field iOS ignores (locationTimeoutMillis)
  // get separate clients, which is harmless.
  private var clients: [FingerprintNativeConfig: FingerprintClientProviding] = [:]
  private let lock = NSLock()

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
    lock.lock()
    defer { lock.unlock() }
    if let existing = clients[config] {
      return existing
    }
    let client = FingerprintFactory.getInstance(buildConfiguration(config: config))
    clients[config] = client
    return client
  }

  private func buildConfiguration(config: FingerprintNativeConfig) -> Configuration {
    // Dart drops empty endpoint strings before they get here.
    let region: Region
    if let endpoint = config.endpoint {
      region = .custom(domain: endpoint, fallback: config.endpointFallbacks ?? [])
    } else {
      switch config.region {
      case .us: region = .global
      case .eu: region = .eu
      case .ap: region = .ap
      }
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
      // Dart validateTags rejects values jsonType cannot convert, so nil is
      // not expected here.
      if let converted = jsonType(from: value) {
        metadata.setTag(converted, forKey: key)
      }
    }
    return metadata
  }
}
