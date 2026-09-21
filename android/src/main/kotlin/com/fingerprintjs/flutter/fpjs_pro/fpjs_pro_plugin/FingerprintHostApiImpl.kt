// Pigeon HostApi: identification via Android Fingerprint SDK 4.x.
package com.fingerprintjs.flutter.fpjs_pro.fpjs_pro_plugin

import android.content.Context
import com.fingerprint.android.Configuration
import com.fingerprint.android.FingerprintResponse

internal class FingerprintHostApiImpl(
  private val applicationContext: Context,
  private val clientCache: FingerprintClientCache = FingerprintClientCache(applicationContext),
) : FingerprintHostApi {

  override fun get(
    config: FingerprintNativeConfig,
    tags: Map<Any?, Any?>?,
    linkedId: String?,
    timeoutMs: Long?,
    callback: (Result<FingerprintNativeResult>) -> Unit,
  ) {
    val nativeConfig = try {
      buildConfiguration(config)
    } catch (error: FlutterError) {
      callback(Result.failure(error))
      return
    }
    val client = clientCache.getOrCreate(nativeConfig, config.pluginVersion)
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

  internal fun buildConfiguration(config: FingerprintNativeConfig): Configuration {
    val region = parseRegion(config.region)
    val endpoints = config.endpoints?.filter { it.isNotEmpty() } ?: emptyList()
    val endpointUrl = if (endpoints.isEmpty()) {
      region.endpointUrl
    } else {
      endpoints.first()
    }
    val fallbacks = if (endpoints.size > 1) {
      endpoints.drop(1)
    } else {
      emptyList()
    }
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

internal fun pigeonTagsToNative(tags: Map<Any?, Any?>?): Map<String, Any> {
  if (tags == null) {
    return emptyMap()
  }
  val result = mutableMapOf<String, Any>()
  for ((key, value) in tags) {
    val stringKey = key as? String ?: continue
    if (value != null) {
      result[stringKey] = value
    }
  }
  return result
}
