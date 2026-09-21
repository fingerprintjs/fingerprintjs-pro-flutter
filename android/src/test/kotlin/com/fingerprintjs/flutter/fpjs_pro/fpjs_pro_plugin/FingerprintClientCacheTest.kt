package com.fingerprintjs.flutter.fpjs_pro.fpjs_pro_plugin

import android.content.Context
import com.fingerprint.android.Configuration
import com.fingerprint.android.Fingerprint
import org.junit.Assert.assertEquals
import org.junit.Test
import org.mockito.Mockito.mock

class FingerprintClientCacheTest {
  private val context = mock(Context::class.java)

  @Test
  fun reusesClientForSameConfiguration() {
    var createCount = 0
    val cache = FingerprintClientCache(context) { _, configuration ->
      createCount += 1
      mock(Fingerprint::class.java)
    }
    val configuration = Configuration(
      "key-a",
      Configuration.Region.US,
      Configuration.Region.US.endpointUrl,
      emptyList(),
      listOf(Pair("fingerprint-pro-flutter", "1.0.0")),
      false,
      5000L,
    )
    val first = cache.getOrCreate(configuration, "1.0.0")
    val second = cache.getOrCreate(configuration, "1.0.0")
    assertEquals(1, createCount)
    assertEquals(first, second)
  }

  @Test
  fun createsNewClientWhenApiKeyChanges() {
    var createCount = 0
    val cache = FingerprintClientCache(context) { _, _ ->
      createCount += 1
      mock(Fingerprint::class.java)
    }
    val base = Configuration(
      "key-a",
      Configuration.Region.US,
      Configuration.Region.US.endpointUrl,
      emptyList(),
      listOf(Pair("fingerprint-pro-flutter", "1.0.0")),
      false,
      5000L,
    )
    cache.getOrCreate(base, "1.0.0")
    val other = Configuration(
      "key-b",
      Configuration.Region.US,
      Configuration.Region.US.endpointUrl,
      emptyList(),
      listOf(Pair("fingerprint-pro-flutter", "1.0.0")),
      false,
      5000L,
    )
    cache.getOrCreate(other, "1.0.0")
    assertEquals(2, createCount)
  }
}
