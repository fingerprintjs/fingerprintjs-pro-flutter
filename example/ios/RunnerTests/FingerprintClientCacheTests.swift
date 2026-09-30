// Verifies that native clients are cached per Pigeon config.

@preconcurrency import Fingerprint
import Foundation
import Testing

@testable import fingerprint_flutter

struct FingerprintClientCacheTests {
  @Test func reusesClientForSameConfiguration() {
    let factory = ClientFactoryRecorder()
    let cache = FingerprintClientCache(createClient: factory.create)
    // Separate values, like two Pigeon calls decode.
    let first = cache.getOrCreate(nativeConfig(endpointFallbacks: ["https://fallback.example.com"]))
    let second = cache.getOrCreate(nativeConfig(endpointFallbacks: ["https://fallback.example.com"]))

    #expect(first === second)
    #expect(factory.callCount == 1)
  }

  @Test func usesSeparateClientsForDifferentConfigurations() {
    // Every pair differs in at least one field.
    let configs = [
      nativeConfig(),
      nativeConfig(apiKey: "other-api-key"),
      nativeConfig(region: .eu),
      nativeConfig(endpoint: "https://example.com"),
      nativeConfig(endpointFallbacks: ["https://fallback.example.com"]),
      nativeConfig(pluginVersion: "2.0.0"),
      nativeConfig(allowUseOfLocationData: true),
    ]
    let cache = FingerprintClientCache(createClient: { _ in StubFingerprintClient() })

    let clients = configs.map { cache.getOrCreate($0) }

    #expect(Set(clients.map(ObjectIdentifier.init)).count == configs.count)
  }

  @Test func createsOneClientDuringConcurrentFirstAccess() {
    let factory = ClientFactoryRecorder(creationDelay: 0.02)
    let cache = FingerprintClientCache(createClient: factory.create)
    let clients = ClientCollector()
    let config = nativeConfig()
    let ready = DispatchSemaphore(value: 0)
    let start = DispatchSemaphore(value: 0)
    let finished = DispatchSemaphore(value: 0)

    let threads = (0..<16).map { _ in
      Thread {
        ready.signal()
        start.wait()
        clients.append(cache.getOrCreate(config))
        finished.signal()
      }
    }
    for thread in threads {
      thread.qualityOfService = .userInteractive
      thread.start()
    }
    for _ in 0..<16 {
      ready.wait()
    }
    for _ in 0..<16 {
      start.signal()
    }
    for _ in 0..<16 {
      finished.wait()
    }

    #expect(factory.callCount == 1)
    #expect(clients.uniqueCount == 1)
  }
}

private func nativeConfig(
  apiKey: String = "api-key",
  region: NativeRegion = .us,
  endpoint: String? = nil,
  endpointFallbacks: [String]? = nil,
  pluginVersion: String = "1.0.0",
  allowUseOfLocationData: Bool = false
) -> FingerprintNativeConfig {
  FingerprintNativeConfig(
    apiKey: apiKey,
    region: region,
    endpoint: endpoint,
    endpointFallbacks: endpointFallbacks,
    pluginVersion: pluginVersion,
    allowUseOfLocationData: allowUseOfLocationData
  )
}

private final class ClientCollector: @unchecked Sendable {
  private let lock = NSLock()
  private var clients: [FingerprintClientProviding] = []

  var uniqueCount: Int {
    lock.withLock { Set(clients.map(ObjectIdentifier.init)).count }
  }

  func append(_ client: FingerprintClientProviding) {
    lock.withLock { clients.append(client) }
  }
}
