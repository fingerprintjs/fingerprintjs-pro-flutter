package com.fingerprint.flutter

import android.content.Context
import com.fingerprint.android.Configuration
import com.fingerprint.android.Fingerprint
import java.util.Collections
import java.util.concurrent.CountDownLatch
import org.junit.Assert.assertNotSame
import org.junit.Assert.assertSame
import org.junit.Test
import org.mockito.Mockito.mock

class FingerprintClientCacheTest {
  private val context = mock(Context::class.java)

  @Test
  fun reusesClientForSameConfiguration() {
    val cache = cache()
    val configuration = configuration()
    val first = cache.getOrCreate(configuration, "1.0.0")
    val second = cache.getOrCreate(configuration, "1.0.0")
    assertSame(first, second)
  }

  @Test
  fun distinctConfigurationsDoNotShareAClient() {
    val cache = cache()
    val base = cache.getOrCreate(configuration(), "1.0.0")
    val variants = listOf(
      cache.getOrCreate(configuration(apiKey = "key-b"), "1.0.0"),
      cache.getOrCreate(configuration(region = Configuration.Region.EU), "1.0.0"),
      cache.getOrCreate(configuration(endpointUrl = "https://custom.example"), "1.0.0"),
      cache.getOrCreate(
        configuration(fallbacks = listOf("https://fallback.example")),
        "1.0.0",
      ),
      cache.getOrCreate(configuration(), "2.0.0"),
      cache.getOrCreate(configuration(allowUseOfLocationData = true), "1.0.0"),
      cache.getOrCreate(configuration(locationTimeoutMillis = 1000L), "1.0.0"),
    )
    for (variant in variants) {
      assertNotSame(base, variant)
    }
  }

  @Test
  fun concurrentFirstAccessReturnsOneClient() {
    val ready = CountDownLatch(16)
    val go = CountDownLatch(1)
    val cache = FingerprintClientCache(context) { _, _ ->
      Thread.sleep(20)
      mock(Fingerprint::class.java)
    }
    val configuration = configuration()
    val clients = Collections.synchronizedList(mutableListOf<Fingerprint>())
    val threads = List(16) {
      Thread {
        ready.countDown()
        go.await()
        clients.add(cache.getOrCreate(configuration, "1.0.0"))
      }
    }
    threads.forEach { it.start() }
    ready.await()
    go.countDown()
    threads.forEach { it.join() }
    assertSame(clients.first(), clients.toSet().single())
  }

  private fun cache() = FingerprintClientCache(context) { _, _ ->
    mock(Fingerprint::class.java)
  }

  private fun configuration(
    apiKey: String = "key-a",
    region: Configuration.Region = Configuration.Region.US,
    endpointUrl: String = region.endpointUrl,
    fallbacks: List<String> = emptyList(),
    pluginVersion: String = "1.0.0",
    allowUseOfLocationData: Boolean = false,
    locationTimeoutMillis: Long = 5000L,
  ) = Configuration(
    apiKey,
    region,
    endpointUrl,
    fallbacks,
    listOf(Pair("fingerprint-flutter", pluginVersion)),
    allowUseOfLocationData,
    locationTimeoutMillis,
  )
}
