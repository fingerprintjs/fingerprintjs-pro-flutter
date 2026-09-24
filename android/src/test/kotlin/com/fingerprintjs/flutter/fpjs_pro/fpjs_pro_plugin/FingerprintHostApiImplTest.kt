package com.fingerprintjs.flutter.fpjs_pro.fpjs_pro_plugin

import android.content.Context
import com.fingerprint.android.ApiKeyRequired
import com.fingerprint.android.Failed
import com.fingerprint.android.Fingerprint
import com.fingerprint.android.FingerprintResponse
import com.fingerprint.android.NetworkError
import com.fingerprint.android.NetworkUnavailableError
import com.fingerprint.android.RequestTimeout
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.mockito.Mockito.mock
import org.mockito.Mockito.`when`

class FingerprintHostApiImplTest {
  private val context = mock(Context::class.java)

  @Test
  fun mapsErrorTypesByInstanceNotSimpleName() {
    val cases = listOf(
      ApiKeyRequired("e1", "msg") to "public_api_key_required",
      Failed("e2", "fail") to "failed",
      RequestTimeout("e3", "timeout") to "request_read_timeout",
      NetworkUnavailableError() to "network_error",
      NetworkError() to "network_error",
    )
    for ((nativeError, expectedCode) in cases) {
      val cache = FingerprintClientCache(context) { _, _ ->
        FakeFingerprint(nativeError)
      }
      var captured: Result<FingerprintNativeResult>? = null
      FingerprintHostApiImpl(context, cache).get(
        FingerprintNativeConfig("key-a", "us", null, null, "1.0.0", false, 5000L),
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
    val cache = FingerprintClientCache(context) { _, _ -> client }
    FingerprintHostApiImpl(context, cache).get(
      FingerprintNativeConfig("key-a", "us", null, null, "1.0.0", false, 5000L),
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
    val cache = FingerprintClientCache(context) { _, _ -> client }
    FingerprintHostApiImpl(context, cache).get(
      FingerprintNativeConfig("key-a", "us", null, null, "1.0.0", false, 5000L),
      null,
      null,
      500L,
    ) {}
    assertEquals(500, client.timeoutMs)
  }

  @Test
  fun getClampsTimeoutOutsideInt() {
    val client = CapturingFingerprint()
    val cache = FingerprintClientCache(context) { _, _ -> client }
    FingerprintHostApiImpl(context, cache).get(
      FingerprintNativeConfig("key-a", "us", null, null, "1.0.0", false, 5000L),
      null,
      null,
      Int.MAX_VALUE.toLong() + 1,
    ) {}
    assertEquals(Int.MAX_VALUE, client.timeoutMs)
  }

  @Test
  fun getUsesDefaultTimeoutOverloadWhenOmitted() {
    val client = CapturingFingerprint()
    val cache = FingerprintClientCache(context) { _, _ -> client }
    FingerprintHostApiImpl(context, cache).get(
      nativeConfig(),
      null,
      null,
      null,
    ) {}
    assertNull(client.timeoutMs)
    assertEquals("", client.linkedId)
  }

  @Test
  fun createUsesRegionUrlWhenEndpointIsEmpty() {
    val built = captureConfiguration(
      nativeConfig(region = "eu", endpoint = ""),
    )
    assertEquals(Configuration.Region.EU.endpointUrl, built.endpointUrl)
  }

  @Test
  fun createUsesCustomEndpoint() {
    val built = captureConfiguration(
      nativeConfig(endpoint = "https://proxy.example"),
    )
    assertEquals("https://proxy.example", built.endpointUrl)
  }

  @Test
  fun createForwardsLocationFlag() {
    val built = captureConfiguration(
      nativeConfig(allowUseOfLocationData = true),
    )
    assertEquals(true, built.allowUseOfLocationData)
  }

  @Test
  fun createUsesProvidedLocationTimeout() {
    val built = captureConfiguration(
      nativeConfig(locationTimeoutMillis = 1000L),
    )
    assertEquals(1000L, built.locationTimeoutMillis)
  }

  @Test
  fun getForwardsLinkedId() {
    val client = CapturingFingerprint()
    val cache = FingerprintClientCache(context) { _, _ -> client }
    FingerprintHostApiImpl(context, cache).get(
      nativeConfig(),
      null,
      "order-1",
      null,
    ) {}
    assertEquals("order-1", client.linkedId)
  }

  @Test
  fun createParsesRegionCaseInsensitively() {
    val cases = listOf(
      "eu" to Configuration.Region.EU,
      "EU" to Configuration.Region.EU,
      "ap" to Configuration.Region.AP,
      "us" to Configuration.Region.US,
      "US" to Configuration.Region.US,
      null to Configuration.Region.US,
    )
    for ((region, expected) in cases) {
      val built = captureConfiguration(nativeConfig(region = region))
      assertEquals(expected, built.region)
    }
  }

  @Test
  fun createRejectsUnknownRegion() {
    try {
      FingerprintHostApiImpl(context, cache()).create(nativeConfig(region = "xx"))
      throw AssertionError("expected FlutterError")
    } catch (error: FlutterError) {
      assertEquals("unknown_error", error.code)
      assertEquals("Invalid region: xx", error.message)
    }
  }

  @Test
  fun getReportsUnknownRegionWithoutCallingClient() {
    var created = false
    val cache = FingerprintClientCache(context) { _, _ ->
      created = true
      mock(Fingerprint::class.java)
    }
    var captured: Result<FingerprintNativeResult>? = null
    FingerprintHostApiImpl(context, cache).get(
      nativeConfig(region = "xx"),
      null,
      null,
      null,
    ) { captured = it }
    assertEquals(false, created)
    val error = captured!!.exceptionOrNull() as FlutterError
    assertEquals("unknown_error", error.code)
  }

  @Test
  fun createDefaultsLocationTimeoutWhenOmitted() {
    val built = captureConfiguration(nativeConfig(locationTimeoutMillis = null))
    assertEquals(5000L, built.locationTimeoutMillis)
  }

  @Test
  fun mapsSuccessfulResponse() {
    val response = mock(FingerprintResponse::class.java)
    `when`(response.eventId).thenReturn("evt-1")
    `when`(response.visitorId).thenReturn("vid-1")
    `when`(response.suspectScore).thenReturn(42)
    `when`(response.sealedResult).thenReturn("sealed")
    val cache = FingerprintClientCache(context) { _, _ ->
      SuccessFingerprint(response)
    }
    var captured: Result<FingerprintNativeResult>? = null
    FingerprintHostApiImpl(context, cache).get(
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

  private fun cache() = FingerprintClientCache(context) { _, _ ->
    mock(Fingerprint::class.java)
  }

  private fun captureConfiguration(config: FingerprintNativeConfig): Configuration {
    var captured: Configuration? = null
    val cache = FingerprintClientCache(context) { _, configuration ->
      captured = configuration
      mock(Fingerprint::class.java)
    }
    FingerprintHostApiImpl(context, cache).create(config)
    return checkNotNull(captured)
  }

  private fun nativeConfig(
    region: String? = "us",
    endpoint: String? = null,
    allowUseOfLocationData: Boolean = false,
    locationTimeoutMillis: Long? = 5000L,
  ) = FingerprintNativeConfig(
    "key-a",
    region,
    endpoint,
    null,
    "1.0.0",
    allowUseOfLocationData,
    locationTimeoutMillis,
  )
}

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
