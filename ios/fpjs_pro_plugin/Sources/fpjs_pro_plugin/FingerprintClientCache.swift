import Foundation
@preconcurrency import Fingerprint

/// One [FingerprintClientProviding] per resolved configuration key.
final class FingerprintClientCache: @unchecked Sendable {
  private var clients: [String: FingerprintClientProviding] = [:]
  private let lock = NSLock()

  func getOrCreate(configuration: Configuration, cacheKey: String) -> FingerprintClientProviding {
    lock.lock()
    defer { lock.unlock() }
    if let existing = clients[cacheKey] {
      return existing
    }
    let client = FingerprintFactory.getInstance(configuration)
    clients[cacheKey] = client
    return client
  }

  func clear() {
    lock.lock()
    defer { lock.unlock() }
    clients.removeAll()
  }
}

func fingerprintCacheKey(
  apiKey: String,
  regionToken: String,
  endpointsToken: String,
  pluginVersion: String,
  allowUseOfLocationData: Bool
) -> String {
  [apiKey, regionToken, endpointsToken, pluginVersion, String(allowUseOfLocationData)]
    .joined(separator: "\u{0000}")
}
