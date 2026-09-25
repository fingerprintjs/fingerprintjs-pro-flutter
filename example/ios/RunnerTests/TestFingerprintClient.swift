// Test client for observing calls at the native SDK interface.

@preconcurrency import Fingerprint
import Foundation

func makeAPIError(code: APIError.Code, eventId: String, message: String) throws -> APIError {
  let data = try JSONSerialization.data(
    withJSONObject: [
      "version": "v4",
      "event_id": eventId,
      "error": [
        "code": code.rawValue,
        "message": message,
      ],
    ]
  )
  return try JSONDecoder().decode(APIError.self, from: data)
}

final class ClientFactoryRecorder: @unchecked Sendable {
  private let lock = NSLock()
  private let client: FingerprintClientProviding?
  private let creationDelay: TimeInterval
  private var configurations: [Configuration] = []

  init(
    client: FingerprintClientProviding? = nil,
    creationDelay: TimeInterval = 0
  ) {
    self.client = client
    self.creationDelay = creationDelay
  }

  var callCount: Int {
    lock.withLock { configurations.count }
  }

  var lastConfiguration: Configuration? {
    lock.withLock { configurations.last }
  }

  func create(_ configuration: Configuration) -> FingerprintClientProviding {
    lock.withLock { configurations.append(configuration) }
    if creationDelay > 0 {
      Thread.sleep(forTimeInterval: creationDelay)
    }
    return client ?? StubFingerprintClient()
  }
}

final class StubFingerprintClient: FingerprintClientProviding, @unchecked Sendable {
  private let lock = NSLock()
  private let result: Result<FingerprintResponse, FPError>
  private var capturedMetadata: Metadata?

  init(
    result: Result<FingerprintResponse, FPError> = .success(
      FingerprintResponse(version: "4.0.0", eventId: "event-id", visitorId: "visitor-id")
    )
  ) {
    self.result = result
  }

  var metadata: Metadata? {
    lock.withLock { capturedMetadata }
  }

  func getVisitorId(_ metadata: Metadata?, timeout: TimeInterval) async throws -> String {
    try lock.withLock { try result.get().visitorId }
  }

  func getVisitorIdResponse(
    _ metadata: Metadata?,
    timeout: TimeInterval
  ) async throws -> FingerprintResponse {
    try lock.withLock { try result.get() }
  }

  func getVisitorId(
    _ metadata: Metadata?,
    timeout: TimeInterval,
    completion: @escaping VisitorIdBlock
  ) {
    let response = record(metadata: metadata)
    completion(response.map(\.visitorId))
  }

  func getVisitorIdResponse(
    _ metadata: Metadata?,
    timeout: TimeInterval,
    completion: @escaping VisitorIdResponseBlock
  ) {
    completion(record(metadata: metadata))
  }

  private func record(metadata: Metadata?) -> Result<FingerprintResponse, FPError> {
    lock.withLock {
      capturedMetadata = metadata
      return result
    }
  }
}
