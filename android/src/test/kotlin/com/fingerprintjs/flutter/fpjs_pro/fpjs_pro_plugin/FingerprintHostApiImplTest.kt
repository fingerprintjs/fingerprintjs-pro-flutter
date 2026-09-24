package com.fingerprintjs.flutter.fpjs_pro.fpjs_pro_plugin

import android.content.Context
import com.fingerprint.android.ApiKeyRequired
import com.fingerprint.android.Configuration
import com.fingerprint.android.Failed
import com.fingerprint.android.Fingerprint
import com.fingerprint.android.FingerprintResponse
import com.fingerprint.android.RequestTimeout
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import org.mockito.Mockito.mock

class FingerprintHostApiImplTest {
  private val context = mock(Context::class.java)

  @Test
  fun createKeepsFallbacksWithoutPrimaryEndpoint() {
    var captured: Configuration? = null
    val cache = FingerprintClientCache(context) { _, configuration ->
      captured = configuration
      mock(Fingerprint::class.java)
    }
    FingerprintHostApiImpl(context, cache).create(
      FingerprintNativeConfig(
        "key-a",
        "us",
        null,
        listOf("https://fallback.example"),
        "1.0.0",
        false,
        5000L,
      ),
    )
    val built = checkNotNull(captured)
    assertEquals(Configuration.Region.US.endpointUrl, built.endpointUrl)
    assertEquals(listOf("https://fallback.example"), built.fallbackEndpointUrls)
  }

  @Test
  fun mapsErrorTypesByInstanceNotSimpleName() {
    val cases = listOf(
      ApiKeyRequired("e1", "msg") to "public_api_key_required",
      Failed("e2", "fail") to "failed",
      RequestTimeout("e3", "timeout") to "request_read_timeout",
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

  override fun getVisitorId(
    tags: Map<String, Any>,
    linkedId: String,
    listener: (FingerprintResponse) -> Unit,
    errorListener: (com.fingerprint.android.Error) -> Unit,
  ) {
    this.tags = tags
  }
}
