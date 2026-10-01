package com.fingerprint.flutter

import android.content.Context
import com.fingerprint.android.ApiKeyRequired
import com.fingerprint.android.Failed
import com.fingerprint.android.Fingerprint
import com.fingerprint.android.FingerprintResponse
import com.fingerprint.android.NetworkUnavailableError
import com.fingerprint.android.RequestTimeout
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.mockito.Mockito.mock

class FingerprintHostApiImplTest {
  private val context = mock(Context::class.java)

  @Test
  fun mapsErrorTypesByInstanceNotSimpleName() {
    val cases = listOf(
      ApiKeyRequired("e1", "msg") to "public_api_key_required",
      Failed("e2", "fail") to "failed",
      RequestTimeout("e3", "timeout") to "request_read_timeout",
      NetworkUnavailableError() to "network_error",
      // NetworkError is left out: its obfuscated static initializer in SDK 4.1.0
      // throws IllegalAccessError on the desktop JVM (works on ART).
    )
    for ((nativeError, expectedCode) in cases) {
      val api = hostApi { _, _ ->
        FakeFingerprint(nativeError)
      }
      var captured: Result<FingerprintNativeResult>? = null
      api.get(
        nativeConfig(),
        null,
        null,
        null,
      ) { captured = it }
      val error = captured!!.exceptionOrNull() as FlutterError
      assertEquals(expectedCode, error.code)
    }
  }

  @Test
  fun getForwardsExplicitNullTagValues() {
    val client = CapturingFingerprint()
    val api = hostApi { _, _ -> client }
    api.get(
      nativeConfig(),
      mapOf("campaign" to null, "sessionId" to 1),
      null,
      null,
    ) {}
    val tags = checkNotNull(client.tags)
    assertTrue(tags.containsKey("campaign"))
    assertEquals(null, tags["campaign"])
    assertEquals(1, tags["sessionId"])
  }

  @Test
  fun getForwardsTimeoutThatFitsInt() {
    val client = CapturingFingerprint()
    val api = hostApi { _, _ -> client }
    api.get(
      nativeConfig(),
      null,
      null,
      500L,
    ) {}
    assertEquals(500, client.timeoutMs)
  }

  @Test
  fun getClampsTimeoutOutsideInt() {
    val client = CapturingFingerprint()
    val api = hostApi { _, _ -> client }
    api.get(
      nativeConfig(),
      null,
      null,
      Int.MAX_VALUE.toLong() + 1,
    ) {}
    assertEquals(Int.MAX_VALUE, client.timeoutMs)
  }

  @Test
  fun getUsesDefaultTimeoutOverloadWhenOmitted() {
    val client = CapturingFingerprint()
    val api = hostApi { _, _ -> client }
    api.get(
      nativeConfig(),
      null,
      null,
      null,
    ) {}
    assertNull(client.timeoutMs)
    assertEquals("", client.linkedId)
  }

  @Test
  fun getForwardsLinkedId() {
    val client = CapturingFingerprint()
    val api = hostApi { _, _ -> client }
    api.get(
      nativeConfig(),
      null,
      "order-1",
      null,
    ) {}
    assertEquals("order-1", client.linkedId)
  }

  @Test
  fun getReportsClientCreationFailureAsUnknownError() {
    val api = hostApi { _, _ -> throw IllegalStateException("bad config") }
    var captured: Result<FingerprintNativeResult>? = null
    api.get(nativeConfig(), null, null, null) { captured = it }
    val error = captured!!.exceptionOrNull() as FlutterError
    assertEquals("unknown_error", error.code)
    assertTrue(error.message!!.contains("bad config"))
    assertNull(error.details)
  }

  @Test
  fun mapsSuccessfulResponse() {
    val response = FingerprintResponse(
      eventId = "evt-1",
      visitorId = "vid-1",
      suspectScore = 42,
      sealedResult = "sealed",
    )
    val api = hostApi { _, _ ->
      SuccessFingerprint(response)
    }
    var captured: Result<FingerprintNativeResult>? = null
    api.get(
      nativeConfig(),
      null,
      null,
      null,
    ) { captured = it }
    val result = captured!!.getOrThrow()
    assertEquals("evt-1", result.eventId)
    assertEquals("vid-1", result.visitorId)
    assertEquals(42L, result.suspectScore)
    assertEquals("sealed", result.sealedResult)
  }

  private fun hostApi(createFingerprint: FingerprintFactoryFn) =
    FingerprintHostApiImpl(context, FingerprintClientCache(context, createFingerprint))
}

internal fun nativeConfig(
  apiKey: String = "key-a",
  region: NativeRegion = NativeRegion.US,
  endpoints: List<String>? = null,
  pluginVersion: String = "1.0.0",
  allowUseOfLocationData: Boolean = false,
  locationTimeoutMillis: Long? = 5000L,
) = FingerprintNativeConfig(
  apiKey,
  region,
  endpoints,
  pluginVersion,
  allowUseOfLocationData,
  locationTimeoutMillis,
)

private class FakeFingerprint(
  private val error: com.fingerprint.android.Error,
) : Fingerprint by mock(Fingerprint::class.java) {
  override fun getVisitorId(
    tags: Map<String, Any>,
    linkedId: String,
    listener: (FingerprintResponse) -> Unit,
    errorListener: (com.fingerprint.android.Error) -> Unit,
  ) {
    errorListener(error)
  }
}

private class CapturingFingerprint : Fingerprint by mock(Fingerprint::class.java) {
  var tags: Map<String, Any>? = null
  var linkedId: String? = null
  var timeoutMs: Int? = null

  override fun getVisitorId(
    tags: Map<String, Any>,
    linkedId: String,
    listener: (FingerprintResponse) -> Unit,
    errorListener: (com.fingerprint.android.Error) -> Unit,
  ) {
    this.tags = tags
    this.linkedId = linkedId
  }

  override fun getVisitorId(
    timeoutMillis: Int,
    tags: Map<String, Any>,
    linkedId: String,
    listener: (FingerprintResponse) -> Unit,
    errorListener: (com.fingerprint.android.Error) -> Unit,
  ) {
    this.timeoutMs = timeoutMillis
    this.tags = tags
    this.linkedId = linkedId
  }
}

private class SuccessFingerprint(
  private val response: FingerprintResponse,
) : Fingerprint by mock(Fingerprint::class.java) {
  override fun getVisitorId(
    tags: Map<String, Any>,
    linkedId: String,
    listener: (FingerprintResponse) -> Unit,
    errorListener: (com.fingerprint.android.Error) -> Unit,
  ) {
    listener(response)
  }
}
