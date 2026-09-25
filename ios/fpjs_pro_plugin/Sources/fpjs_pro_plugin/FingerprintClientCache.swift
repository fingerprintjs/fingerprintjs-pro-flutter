@preconcurrency import Fingerprint
import Foundation

/// One [FingerprintClientProviding] per resolved configuration.
final class FingerprintClientCache: @unchecked Sendable {
  // Fields, not a joined string. A delimiter key can collide or drop a field.
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
  private let createClient: (Configuration) -> FingerprintClientProviding
  private let lock = NSLock()

  init(
    createClient: @escaping (Configuration) -> FingerprintClientProviding = {
      FingerprintFactory.getInstance($0)
    }
  ) {
    self.createClient = createClient
  }

  func getOrCreate(
    configuration: Configuration,
    pluginVersion: String
  ) -> FingerprintClientProviding {
    lock.lock()
    defer { lock.unlock() }
    let key = ClientKey(configuration: configuration, pluginVersion: pluginVersion)
    if let existing = clients[key] {
      return existing
    }
    let client = createClient(configuration)
    clients[key] = client
    return client
  }
}
