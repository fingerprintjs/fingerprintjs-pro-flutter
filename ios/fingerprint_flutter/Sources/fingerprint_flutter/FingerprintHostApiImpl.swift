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
    _ = clientCache.getOrCreate(config)
  }

  func get(
    config: FingerprintNativeConfig,
    tags: [String?: Any?]?,
    linkedId: String?,
    timeoutMs: Int64?,
    completion: @escaping (Result<FingerprintNativeResult, Error>) -> Void
  ) {
    let client = clientCache.getOrCreate(config)
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
