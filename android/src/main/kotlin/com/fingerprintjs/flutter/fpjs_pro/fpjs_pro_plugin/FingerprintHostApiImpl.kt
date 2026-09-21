// Pigeon HostApi: identification via Android Fingerprint SDK 4.x.
package com.fingerprintjs.flutter.fpjs_pro.fpjs_pro_plugin

import android.content.Context
import com.fingerprint.android.Configuration
import com.fingerprint.android.FingerprintResponse

internal class FingerprintHostApiImpl(
  private val applicationContext: Context,
  private val clientCache: FingerprintClientCache = FingerprintClientCache(applicationContext),
) : FingerprintHostApi {

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
    val client = try {
      nativeClient(config)
    } catch (error: FlutterError) {
      callback(Result.failure(error))
      return
    }
    val tagMap = pigeonTagsToNative(tags)
    val linked = linkedId ?: ""
    val listener: (FingerprintResponse) -> Unit = { response ->
      callback(
        Result.success(
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
      client.getVisitorId(timeoutMs.toInt(), tagMap, linked, listener, errorListener)
    } else {
      client.getVisitorId(tagMap, linked, listener, errorListener)
    }
  }

  private fun nativeClient(config: FingerprintNativeConfig) =
    clientCache.getOrCreate(buildConfiguration(config), config.pluginVersion)

  private fun buildConfiguration(config: FingerprintNativeConfig): Configuration {
    val region = parseRegion(config.region)
    val endpointUrl = config.endpoint?.takeIf { it.isNotEmpty() } ?: region.endpointUrl
    val fallbacks = config.endpointFallbacks?.filter { it.isNotEmpty() } ?: emptyList()
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

internal fun parseRegion(region: String?): Configuration.Region {
  return when (region?.lowercase()) {
    "eu" -> Configuration.Region.EU
    "ap" -> Configuration.Region.AP
    "us", null -> Configuration.Region.US
    else -> throw FlutterError("unknown_error", "Invalid region: $region", null)
  }
}

internal fun pigeonTagsToNative(tags: Map<String?, Any?>?): Map<String, Any> {
  if (tags == null) {
    return emptyMap()
  }
  val result = mutableMapOf<String, Any>()
  for ((key, value) in tags) {
    if (key != null && value != null) {
      result[key] = value
    }
  }
  return result
}
