package com.fingerprintjs.flutter.fpjs_pro.fpjs_pro_plugin

import android.content.Context
import com.fingerprint.android.Fingerprint
import org.junit.Assert.assertEquals
import org.junit.Test
import org.mockito.Mockito.mock

class FingerprintHostApiImplTest {
  private val context = mock(Context::class.java)

  @Test
  fun createBuildsOneClientForTheSameConfig() {
    var createCount = 0
    val cache = FingerprintClientCache(context) { _, _ ->
      createCount += 1
      mock(Fingerprint::class.java)
    }
    val api = FingerprintHostApiImpl(context, cache)
    val config = FingerprintNativeConfig(
      "key-a",
      "us",
      null,
      "1.0.0",
      false,
      5000L,
    )
    api.create(config)
    api.create(config)
    assertEquals(1, createCount)
  }
}
