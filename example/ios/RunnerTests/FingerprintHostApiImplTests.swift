// Verifies the Pigeon host API contract against a controlled native SDK client.

@preconcurrency import Fingerprint
import XCTest

@testable import fpjs_pro_plugin

final class FingerprintHostApiImplTests: XCTestCase {
  func testCreateBuildsConfigurationWithRegionFallbacks() throws {
    let factory = ClientFactoryRecorder(client: StubFingerprintClient())
    let cache = FingerprintClientCache(createClient: factory.create)
    let hostApi = FingerprintHostApiImpl(clientCache: cache)

    try hostApi.create(
      config: FingerprintNativeConfig(
        apiKey: "api-key",
        region: "eu",
        endpointFallbacks: ["", "https://fallback.example.com"],
        pluginVersion: "1.2.3",
        allowUseOfLocationData: true
      )
    )

    let configuration = try XCTUnwrap(factory.lastConfiguration)
    XCTAssertEqual(configuration.apiKey, "api-key")
    XCTAssertEqual(configuration.allowUseOfLocationData, true)
    XCTAssertEqual(configuration.integrationInfo.first?.0, "fingerprint-pro-flutter")
    XCTAssertEqual(configuration.integrationInfo.first?.1, "1.2.3")
    guard case .custom(let domain, let fallback) = configuration.region else {
      return XCTFail("Expected a custom region")
    }
    XCTAssertEqual(domain, "https://eu.api.fpjs.io")
    XCTAssertEqual(fallback, ["https://fallback.example.com"])
  }

  func testGetForwardsMetadataIncludingExplicitNullTags() throws {
    let client = StubFingerprintClient()
    let factory = ClientFactoryRecorder(client: client)
    let hostApi = FingerprintHostApiImpl(
      clientCache: FingerprintClientCache(createClient: factory.create)
    )
    let tags: [String?: Any?] = [
      "campaign": nil,
      "sessionId": 1,
      "nested": ["missing": NSNull(), "active": true],
    ]

    hostApi.get(
      config: FingerprintNativeConfig(
        apiKey: "api-key",
        pluginVersion: "1.2.3",
        allowUseOfLocationData: false
      ),
      tags: tags,
      linkedId: "linked-id",
      timeoutMs: nil
    ) { _ in }

    let metadata = try XCTUnwrap(client.metadata)
    XCTAssertEqual(metadata.linkedId, "linked-id")
    XCTAssertEqual(
      metadata.tags,
      [
        "campaign": .null,
        "sessionId": .int(1),
        "nested": .object(["missing": .null, "active": .bool(true)]),
      ]
    )
  }

  func testGetMapsApiErrorCodes() throws {
    let cases = [
      (APIError.Code.publicApiKeyRequired, "public_api_key_required"),
      (.failed, "failed"),
      (.requestReadTimeout, "request_read_timeout"),
    ]

    for (nativeCode, expectedCode) in cases {
      let apiError = try makeAPIError(code: nativeCode, eventId: "event-id", message: "message")
      let client = StubFingerprintClient(result: .failure(.apiError(apiError)))
      let hostApi = FingerprintHostApiImpl(
        clientCache: FingerprintClientCache(
          createClient: ClientFactoryRecorder(client: client).create
        )
      )
      var captured: Result<FingerprintNativeResult, Error>?

      hostApi.get(
        config: FingerprintNativeConfig(
          apiKey: "api-key",
          pluginVersion: "1.2.3",
          allowUseOfLocationData: false
        ),
        tags: nil,
        linkedId: nil,
        timeoutMs: nil
      ) { captured = $0 }

      guard case .failure(let capturedError) = try XCTUnwrap(captured) else {
        return XCTFail("Expected an error")
      }
      let error = try XCTUnwrap(capturedError as? PigeonError)
      XCTAssertEqual(error.code, expectedCode)
    }
  }
}
