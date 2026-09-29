// Verifies the Pigeon host API contract against a controlled native SDK client.

@preconcurrency import Fingerprint
import Foundation
import Testing

@testable import fpjs_pro_plugin

struct FingerprintHostApiImplTests {
  @Test func createBuildsCustomRegionFromEndpointAndFallbacks() throws {
    let factory = ClientFactoryRecorder(client: StubFingerprintClient())
    let hostApi = FingerprintHostApiImpl(
      clientCache: FingerprintClientCache(createClient: factory.create)
    )

    try hostApi.create(
      config: FingerprintNativeConfig(
        apiKey: "api-key",
        endpoint: "https://custom.example.com",
        endpointFallbacks: ["https://fallback.example.com"],
        pluginVersion: "1.2.3",
        allowUseOfLocationData: true
      )
    )

    let configuration = try #require(factory.lastConfiguration)
    #expect(configuration.apiKey == "api-key")
    #expect(configuration.allowUseOfLocationData == true)
    #expect(configuration.integrationInfo.first?.0 == "fingerprint-pro-flutter")
    #expect(configuration.integrationInfo.first?.1 == "1.2.3")
    #expect(
      configuration.region
        == .custom(
          domain: "https://custom.example.com",
          fallback: ["https://fallback.example.com"]
        )
    )
  }

  @Test func createUsesNamedRegionWhenEndpointIsMissing() throws {
    let factory = ClientFactoryRecorder(client: StubFingerprintClient())
    let hostApi = FingerprintHostApiImpl(
      clientCache: FingerprintClientCache(createClient: factory.create)
    )

    try hostApi.create(
      config: FingerprintNativeConfig(
        apiKey: "api-key",
        region: "eu",
        pluginVersion: "1.2.3",
        allowUseOfLocationData: false
      )
    )

    let configuration = try #require(factory.lastConfiguration)
    #expect(configuration.region == .eu)
  }

  @Test func getForwardsMetadataIncludingExplicitNullTags() throws {
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

    let metadata = try #require(client.metadata)
    #expect(metadata.linkedId == "linked-id")
    #expect(
      metadata.tags == [
        "campaign": .null,
        "sessionId": .int(1),
        "nested": .object(["missing": .null, "active": .bool(true)]),
      ]
    )
  }

  @Test(arguments: [
    (APIError.Code.publicApiKeyRequired, "public_api_key_required"),
    (.failed, "failed"),
    (.requestReadTimeout, "request_read_timeout"),
  ])
  func getMapsApiErrorCodes(nativeCode: APIError.Code, expectedCode: String) throws {
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

    guard case .failure(let error as PigeonError) = try #require(captured) else {
      Issue.record("Expected a PigeonError")
      return
    }
    #expect(error.code == expectedCode)
  }

  @Test func getForwardsTimeoutInSeconds() {
    let client = StubFingerprintClient()
    let hostApi = FingerprintHostApiImpl(
      clientCache: FingerprintClientCache(
        createClient: ClientFactoryRecorder(client: client).create
      )
    )

    hostApi.get(
      config: FingerprintNativeConfig(
        apiKey: "api-key",
        pluginVersion: "1.2.3",
        allowUseOfLocationData: false
      ),
      tags: nil,
      linkedId: nil,
      timeoutMs: 1500
    ) { _ in }

    #expect(client.timeout == 1.5)
  }
}
