package com.fingerprint.flutter

import android.content.Context
import com.fingerprint.android.Configuration
import com.fingerprint.android.Fingerprint
import java.util.concurrent.CountDownLatch
import java.util.concurrent.atomic.AtomicInteger
import org.junit.Assert.assertEquals
import org.junit.Test
import org.mockito.Mockito.mock

class FingerprintClientCacheTest {
  private val context = mock(Context::class.java)

  @Test
  fun reusesClientForEqualConfig() {
    val created = AtomicInteger()
    val cache = FingerprintClientCache(context) { _, _ ->
      created.incrementAndGet()
      mock(Fingerprint::class.java)
    }
    // Separate instances, like two Pigeon calls decode.
    cache.getOrCreate(nativeConfig(fallbacks = listOf("https://fallback.example")))
    cache.getOrCreate(nativeConfig(fallbacks = listOf("https://fallback.example")))
    assertEquals(1, created.get())
  }

  @Test
  fun distinctConfigsDoNotShareAClient() {
    val created = AtomicInteger()
    val cache = FingerprintClientCache(context) { _, _ ->
      created.incrementAndGet()
      mock(Fingerprint::class.java)
    }
    val configs = listOf(
      nativeConfig(),
      nativeConfig(apiKey = "key-b"),
      nativeConfig(region = NativeRegion.EU),
      nativeConfig(endpoint = "https://custom.example"),
      nativeConfig(fallbacks = listOf("https://fallback.example")),
      nativeConfig(pluginVersion = "2.0.0"),
      nativeConfig(allowUseOfLocationData = true),
      nativeConfig(locationTimeoutMillis = 1000L),
    )
    configs.forEach { cache.getOrCreate(it) }
    assertEquals(configs.size, created.get())
  }

  @Test
  fun concurrentFirstAccessCreatesOneClient() {
    val created = AtomicInteger()
    val cache = FingerprintClientCache(context) { _, _ ->
      created.incrementAndGet()
      Thread.sleep(20)
      mock(Fingerprint::class.java)
    }
    val ready = CountDownLatch(16)
    val go = CountDownLatch(1)
    val threads = List(16) {
      Thread {
        ready.countDown()
        go.await()
        cache.getOrCreate(nativeConfig())
      }
    }
    threads.forEach { it.start() }
    ready.await()
    go.countDown()
    threads.forEach { it.join() }
    assertEquals(1, created.get())
  }

  @Test
  fun usesRegionUrlWhenEndpointIsOmitted() {
    val built = buildConfiguration(nativeConfig(region = NativeRegion.EU, endpoint = null))
    assertEquals(Configuration.Region.EU.endpointUrl, built.endpointUrl)
  }

  @Test
  fun usesCustomEndpointAndFallbacks() {
    val built = buildConfiguration(
      nativeConfig(endpoint = "https://proxy.example", fallbacks = listOf("https://fallback.example")),
    )
    assertEquals("https://proxy.example", built.endpointUrl)
    assertEquals(listOf("https://fallback.example"), built.fallbackEndpointUrls)
  }

  @Test
  fun mapsRegions() {
    val cases = listOf(
      NativeRegion.EU to Configuration.Region.EU,
      NativeRegion.AP to Configuration.Region.AP,
      NativeRegion.US to Configuration.Region.US,
    )
    for ((region, expected) in cases) {
      assertEquals(expected, buildConfiguration(nativeConfig(region = region)).region)
    }
  }

  @Test
  fun forwardsLocationSettings() {
    val built = buildConfiguration(
      nativeConfig(allowUseOfLocationData = true, locationTimeoutMillis = 1000L),
    )
    assertEquals(true, built.allowUseOfLocationData)
    assertEquals(1000L, built.locationTimeoutMillis)
  }

  @Test
  fun usesSdkDefaultLocationTimeoutWhenOmitted() {
    val built = buildConfiguration(nativeConfig(locationTimeoutMillis = null))
    assertEquals(Configuration.DEFAULT_LOCATION_TIMEOUT_MILLIS, built.locationTimeoutMillis)
  }

  // The Configuration the cache passes to the SDK factory.
  private fun buildConfiguration(config: FingerprintNativeConfig): Configuration {
    var captured: Configuration? = null
    FingerprintClientCache(context) { _, configuration ->
      captured = configuration
      mock(Fingerprint::class.java)
    }.getOrCreate(config)
    return checkNotNull(captured)
  }
}
