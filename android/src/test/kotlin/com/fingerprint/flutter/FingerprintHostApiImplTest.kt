package com.fingerprint.flutter

import android.content.Context
import com.fingerprint.android.ApiKeyRequired
import com.fingerprint.android.Failed
import com.fingerprint.android.Fingerprint
import com.fingerprint.android.FingerprintResponse
import com.fingerprint.android.NetworkUnavailableError
import com.fingerprint.android.RequestTimeout
import org.junit.Assert.assertEquals
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
  var timeoutMs: Int? = null

  override fun getVisitorId(
    tags: Map<String, Any>,
    linkedId: String,
    listener: (FingerprintResponse) -> Unit,
    errorListener: (com.fingerprint.android.Error) -> Unit,
  ) {
    this.tags = tags
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
  }
}
