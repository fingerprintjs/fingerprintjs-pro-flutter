import Foundation
@preconcurrency import Fingerprint

/// One [FingerprintClientProviding] per resolved configuration.
final class FingerprintClientCache: @unchecked Sendable {
  private struct ClientKey: Hashable {
    var apiKey: String
    var regionCode: String
    var customDomain: String?
    var customFallbacks: [String]
    var pluginVersion: String
    var allowUseOfLocationData: Bool

    init(configuration: Configuration, pluginVersion: String) {
      apiKey = configuration.apiKey
      self.pluginVersion = pluginVersion
      allowUseOfLocationData = configuration.allowUseOfLocationData
      switch configuration.region {
      case .eu:
        regionCode = "eu"
        customDomain = nil
        customFallbacks = []
      case .ap:
        regionCode = "ap"
        customDomain = nil
        customFallbacks = []
      case .custom(let domain, let fallback):
        regionCode = "custom"
        customDomain = domain
        customFallbacks = fallback
      default:
        regionCode = "global"
        customDomain = nil
        customFallbacks = []
      }
    }
  }

  private var clients: [ClientKey: FingerprintClientProviding] = [:]
  private let lock = NSLock()

  func getOrCreate(configuration: Configuration, pluginVersion: String) -> FingerprintClientProviding {
    lock.lock()
    defer { lock.unlock() }
    let key = ClientKey(configuration: configuration, pluginVersion: pluginVersion)
    if let existing = clients[key] {
      return existing
    }
    let client = FingerprintFactory.getInstance(configuration)
    clients[key] = client
    return client
  }
}
