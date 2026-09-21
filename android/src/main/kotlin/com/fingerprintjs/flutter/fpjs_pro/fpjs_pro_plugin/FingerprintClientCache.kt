// Memoizes Fingerprint clients by resolved native configuration.
package com.fingerprintjs.flutter.fpjs_pro.fpjs_pro_plugin

import android.content.Context
import com.fingerprint.android.Configuration
import com.fingerprint.android.Fingerprint
import com.fingerprint.android.FingerprintFactory
import java.util.concurrent.ConcurrentHashMap

internal typealias FingerprintFactoryFn = (Context, Configuration) -> Fingerprint

internal fun configCacheKey(
  apiKey: String,
  region: Configuration.Region,
  endpointUrl: String,
  fallbackEndpointUrls: List<String>,
  pluginVersion: String,
  allowUseOfLocationData: Boolean,
  locationTimeoutMillis: Long,
): String = listOf(
  apiKey,
  region.name,
  endpointUrl,
  fallbackEndpointUrls.joinToString("\u0001"),
  pluginVersion,
  allowUseOfLocationData.toString(),
  locationTimeoutMillis.toString(),
).joinToString("\u0000")

internal class FingerprintClientCache(
  private val applicationContext: Context,
  private val createFingerprint: FingerprintFactoryFn = { context, configuration ->
    FingerprintFactory(context).createInstance(configuration)
  },
) {
  private val clients = ConcurrentHashMap<String, Fingerprint>()

  fun getOrCreate(configuration: Configuration, pluginVersion: String): Fingerprint {
    val key = configCacheKey(
      configuration.apiKey,
      configuration.region,
      configuration.endpointUrl,
      configuration.fallbackEndpointUrls,
      pluginVersion,
      configuration.allowUseOfLocationData,
      configuration.locationTimeoutMillis,
    )
    return clients.getOrPut(key) {
      createFingerprint(applicationContext, configuration)
    }
  }

  fun clear() {
    clients.clear()
  }
}
