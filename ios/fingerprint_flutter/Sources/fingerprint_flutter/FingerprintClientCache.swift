// One iOS Fingerprint client per Pigeon config.
@preconcurrency import Fingerprint
import Foundation

final class FingerprintClientCache: @unchecked Sendable {
  // Pigeon generates Hashable for the config, so new fields are part of the
  // key automatically. Configs that differ only in a field iOS ignores
  // (locationTimeoutMillis) get separate clients, which is harmless.
  private var clients: [FingerprintNativeConfig: FingerprintClientProviding] = [:]
  private let createClient: (Configuration) -> FingerprintClientProviding
  private let lock = NSLock()

  // Client creation runs on the Pigeon background queue. No hop to main is
  // needed: the SDK starts location updates on the main thread itself.
  init(
    createClient: @escaping (Configuration) -> FingerprintClientProviding = {
      FingerprintFactory.getInstance($0)
    }
  ) {
    self.createClient = createClient
  }

  func getOrCreate(_ config: FingerprintNativeConfig) -> FingerprintClientProviding {
    lock.lock()
    defer { lock.unlock() }
    if let existing = clients[config] {
      return existing
    }
    let client = createClient(buildConfiguration(config: config))
    clients[config] = client
    return client
  }

  private func buildConfiguration(config: FingerprintNativeConfig) -> Configuration {
    // Dart drops empty endpoint strings and sends nil, not an empty list.
    let region: Region
    if let endpoints = config.endpoints, let endpoint = endpoints.first {
      region = .custom(domain: endpoint, fallback: Array(endpoints.dropFirst()))
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
}
