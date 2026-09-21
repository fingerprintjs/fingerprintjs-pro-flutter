package com.fingerprintjs.flutter.fpjs_pro.fpjs_pro_plugin

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

  @Test
  fun createsNewClientWhenFallbacksChange() {
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
      "key-a",
      Configuration.Region.US,
      Configuration.Region.US.endpointUrl,
      listOf("https://fallback.example"),
      listOf(Pair("fingerprint-pro-flutter", "1.0.0")),
      false,
      5000L,
    )
    cache.getOrCreate(other, "1.0.0")
    assertEquals(2, createCount)
  }

  @Test
  fun createsClientOnceUnderConcurrentFirstAccess() {
    val ready = CountDownLatch(16)
    val go = CountDownLatch(1)
    val created = AtomicInteger(0)
    val cache = FingerprintClientCache(context) { _, _ ->
      created.incrementAndGet()
      Thread.sleep(20)
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
    val threads = List(16) {
      Thread {
        ready.countDown()
        go.await()
        cache.getOrCreate(configuration, "1.0.0")
      }
    }
    threads.forEach { it.start() }
    ready.await()
    go.countDown()
    threads.forEach { it.join() }
    assertEquals(1, created.get())
  }
}
