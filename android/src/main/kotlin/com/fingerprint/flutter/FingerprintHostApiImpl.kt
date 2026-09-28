// Pigeon HostApi: identification via Android Fingerprint SDK 4.x.
package com.fingerprint.flutter

import android.content.Context
import com.fingerprint.android.Configuration
import com.fingerprint.android.Fingerprint
import com.fingerprint.android.FingerprintFactory
import com.fingerprint.android.FingerprintResponse
import java.util.concurrent.ConcurrentHashMap

internal typealias FingerprintFactoryFn = (Context, Configuration) -> Fingerprint

internal class FingerprintHostApiImpl(
  private val applicationContext: Context,
  private val createFingerprint: FingerprintFactoryFn = { context, configuration ->
    FingerprintFactory(context).createInstance(configuration)
  },
) : FingerprintHostApi {
  // One client per config. Pigeon generates value equality for the config.
  // Configs that only resolve to the same Configuration (no endpoint vs the
  // region's default URL) get separate clients, which is harmless.
  private val clients = ConcurrentHashMap<FingerprintNativeConfig, Fingerprint>()

  override fun create(config: FingerprintNativeConfig) {
    nativeClient(config)
  }

  override fun get(
    config: FingerprintNativeConfig,
    tags: Map<String?, Any?>?,
    linkedId: String?,
    timeoutMs: Long?,
    callback: (Result<FingerprintNativeResult>) -> Unit,
  ) {
    val client = nativeClient(config)
    val tagMap = pigeonTagsToNative(tags)
    val linked = linkedId ?: ""
    val listener: (FingerprintResponse) -> Unit = { response ->
      callback(
        Result.success(
          // Native FingerprintResponse -> Pigeon result.
          FingerprintNativeResult(
            eventId = response.eventId,
            visitorId = response.visitorId,
            suspectScore = response.suspectScore?.toLong(),
            sealedResult = response.sealedResult,
          ),
        ),
      )
    }
    val errorListener: (com.fingerprint.android.Error) -> Unit = { error ->
      callback(Result.failure(toFlutterError(error)))
    }
    if (timeoutMs != null) {
      // Android getVisitorId takes Int. Long.toInt() wraps. Clamp so a huge timeout becomes Int.MAX_VALUE, not negative.
      val timeoutInt =
        timeoutMs.coerceIn(Int.MIN_VALUE.toLong(), Int.MAX_VALUE.toLong()).toInt()
      client.getVisitorId(timeoutInt, tagMap, linked, listener, errorListener)
    } else {
      client.getVisitorId(tagMap, linked, listener, errorListener)
    }
  }

  // Kotlin ConcurrentHashMap.getOrPut is not atomic: concurrent first hits can
  // each create a Fingerprint client. computeIfAbsent runs the factory once.
  // https://kotlinlang.org/api/core/kotlin-stdlib/kotlin.collections/get-or-put.html
  private fun nativeClient(config: FingerprintNativeConfig): Fingerprint =
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
    val locationTimeout = config.locationTimeoutMillis ?: 5000L
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

// Keep JSON null values. The SDK type is Map<String, Any>, so this is an
// unchecked cast of a HashMap that may contain nulls. Null keys cannot
// be stored.
// https://docs.fingerprint.com/docs/tagging-information
internal fun pigeonTagsToNative(tags: Map<String?, Any?>?): Map<String, Any> {
  if (tags == null) {
    return emptyMap()
  }
  val result = HashMap<String, Any?>(tags.size)
  for ((key, value) in tags) {
    if (key != null) {
      result[key] = value
    }
  }
  @Suppress("UNCHECKED_CAST")
  return result as Map<String, Any>
}
