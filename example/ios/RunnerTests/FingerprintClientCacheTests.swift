// Verifies that native clients are cached by their complete configuration.

@preconcurrency import Fingerprint
import Foundation
import XCTest

@testable import fpjs_pro_plugin

final class FingerprintClientCacheTests: XCTestCase {
  func testReusesClientForSameConfiguration() {
    let factory = ClientFactoryRecorder()
    let cache = FingerprintClientCache(createClient: factory.create)
    let configuration = Configuration(apiKey: "api-key")

    let first = cache.getOrCreate(configuration: configuration, pluginVersion: "1.0.0")
    let second = cache.getOrCreate(configuration: configuration, pluginVersion: "1.0.0")

    XCTAssertTrue(first === second)
    XCTAssertEqual(factory.callCount, 1)
  }

  func testUsesSeparateClientsForDifferentConfigurations() {
    // Every pair differs in at least one key field.
    let cases: [(Configuration, String)] = [
      (Configuration(apiKey: "api-key"), "1.0.0"),
      (Configuration(apiKey: "other-api-key"), "1.0.0"),
      (Configuration(apiKey: "api-key", region: .eu), "1.0.0"),
      (Configuration(apiKey: "api-key", region: .custom(domain: "https://example.com")), "1.0.0"),
      (
        Configuration(apiKey: "api-key", region: .custom(domain: "https://other.example.com")),
        "1.0.0"
      ),
      (
        Configuration(
          apiKey: "api-key",
          region: .custom(
            domain: "https://example.com",
            fallback: ["https://fallback.example.com"]
          )
        ),
        "1.0.0"
      ),
      (Configuration(apiKey: "api-key"), "2.0.0"),
      (Configuration(apiKey: "api-key", allowUseOfLocationData: true), "1.0.0"),
    ]
    let cache = FingerprintClientCache(createClient: { _ in StubFingerprintClient() })

    let clients = cases.map { configuration, pluginVersion in
      cache.getOrCreate(configuration: configuration, pluginVersion: pluginVersion)
    }

    XCTAssertEqual(Set(clients.map(ObjectIdentifier.init)).count, cases.count)
  }

  func testCreatesOneClientDuringConcurrentFirstAccess() {
    let factory = ClientFactoryRecorder(creationDelay: 0.02)
    let cache = FingerprintClientCache(createClient: factory.create)
    let clients = ClientCollector()
    let configuration = Configuration(apiKey: "api-key")
    let ready = DispatchSemaphore(value: 0)
    let start = DispatchSemaphore(value: 0)
    let finished = DispatchSemaphore(value: 0)

    let threads = (0..<16).map { _ in
      Thread {
        ready.signal()
        start.wait()
        clients.append(
          cache.getOrCreate(configuration: configuration, pluginVersion: "1.0.0")
        )
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

    XCTAssertEqual(factory.callCount, 1)
    XCTAssertEqual(clients.uniqueCount, 1)
  }
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
