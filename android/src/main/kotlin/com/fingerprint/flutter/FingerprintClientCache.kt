// One Android Fingerprint client per Pigeon config.
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
  // Pigeon generates value equality for the config, so new fields are part
  // of the key automatically. Configs that only resolve to the same
  // Configuration (no endpoint vs the region's default URL) get separate
  // clients, which is harmless.
  private val clients = ConcurrentHashMap<FingerprintNativeConfig, Fingerprint>()

  // Kotlin ConcurrentHashMap.getOrPut is not atomic: concurrent first hits can
  // each create a Fingerprint client. computeIfAbsent runs the factory once.
  // https://kotlinlang.org/api/core/kotlin-stdlib/kotlin.collections/get-or-put.html
  fun getOrCreate(config: FingerprintNativeConfig): Fingerprint =
    clients.computeIfAbsent(config) {
      createFingerprint(applicationContext, buildConfiguration(config))
    }

  private fun buildConfiguration(config: FingerprintNativeConfig): Configuration {
    val region = when (config.region) {
      NativeRegion.US -> Configuration.Region.US
      NativeRegion.EU -> Configuration.Region.EU
      NativeRegion.AP -> Configuration.Region.AP
    }
    // Dart drops empty endpoint strings before they get here.
    val endpointUrl = config.endpoint ?: region.endpointUrl
    val fallbacks = config.endpointFallbacks ?: emptyList()
    val locationTimeout = config.locationTimeoutMillis ?: Configuration.DEFAULT_LOCATION_TIMEOUT_MILLIS
    return Configuration(
      config.apiKey,
      region,
      endpointUrl,
      fallbacks,
      listOf(Pair("fingerprint-pro-flutter", config.pluginVersion)),
      config.allowUseOfLocationData,
      locationTimeout,
    )
  }
}
