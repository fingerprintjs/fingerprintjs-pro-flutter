// Memoizes Fingerprint clients by resolved native configuration.
package com.fingerprint.flutter

import android.content.Context
import com.fingerprint.android.Configuration
import com.fingerprint.android.Fingerprint
import com.fingerprint.android.FingerprintFactory
import java.util.concurrent.ConcurrentHashMap

internal typealias FingerprintFactoryFn = (Context, Configuration) -> Fingerprint

internal class FingerprintClientCache(
  private val applicationContext: Context,
  private val createFingerprint: FingerprintFactoryFn = { context, configuration ->
    FingerprintFactory(context).createInstance(configuration)
  },
) {
  // Fields, not a joined string. A delimiter key can collide or drop a field.
  private data class ClientKey(
    val apiKey: String,
    val region: Configuration.Region,
    val endpointUrl: String,
    val fallbackEndpointUrls: List<String>,
    val pluginVersion: String,
    val allowUseOfLocationData: Boolean,
    val locationTimeoutMillis: Long,
  )

  private val clients = ConcurrentHashMap<ClientKey, Fingerprint>()

  fun getOrCreate(configuration: Configuration, pluginVersion: String): Fingerprint {
    val key = ClientKey(
      configuration.apiKey,
      configuration.region,
      configuration.endpointUrl,
      configuration.fallbackEndpointUrls.toList(),
      pluginVersion,
      configuration.allowUseOfLocationData,
      configuration.locationTimeoutMillis,
    )
    // Kotlin ConcurrentHashMap.getOrPut is not atomic: concurrent first hits can
    // each create a Fingerprint client. computeIfAbsent runs the factory once.
    // https://kotlinlang.org/api/core/kotlin-stdlib/kotlin.collections/get-or-put.html
    return clients.computeIfAbsent(key) {
      createFingerprint(applicationContext, configuration)
    }
  }
}
