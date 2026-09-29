// One iOS Fingerprint client per Pigeon config.
import Foundation
@preconcurrency import Fingerprint

final class FingerprintClientCache: @unchecked Sendable {
  // Pigeon generates Hashable for the config, so new fields are part of the
  // key automatically. Configs that differ only in a field iOS ignores
  // (locationTimeoutMillis) get separate clients, which is harmless.
  private var clients: [FingerprintNativeConfig: FingerprintClientProviding] = [:]
  private let lock = NSLock()

  func getOrCreate(_ config: FingerprintNativeConfig) -> FingerprintClientProviding {
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
}
