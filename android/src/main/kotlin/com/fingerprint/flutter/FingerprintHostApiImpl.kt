// Pigeon HostApi: identification via Android Fingerprint SDK 4.x.
package com.fingerprint.flutter

import android.content.Context
import com.fingerprint.android.FingerprintResponse

internal class FingerprintHostApiImpl(
  applicationContext: Context,
  private val clientCache: FingerprintClientCache = FingerprintClientCache(applicationContext),
) : FingerprintHostApi {

  override fun create(config: FingerprintNativeConfig) {
    clientCache.getOrCreate(config)
  }

  override fun get(
    config: FingerprintNativeConfig,
    tags: Map<String?, Any?>?,
    linkedId: String?,
    timeoutMs: Long?,
    callback: (Result<FingerprintNativeResult>) -> Unit,
  ) {
    val client = clientCache.getOrCreate(config)
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
      // Dart rejects negative timeouts, so only the upper bound matters.
      val timeoutInt = timeoutMs.coerceAtMost(Int.MAX_VALUE.toLong()).toInt()
      client.getVisitorId(timeoutInt, tagMap, linked, listener, errorListener)
    } else {
      client.getVisitorId(tagMap, linked, listener, errorListener)
    }
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
