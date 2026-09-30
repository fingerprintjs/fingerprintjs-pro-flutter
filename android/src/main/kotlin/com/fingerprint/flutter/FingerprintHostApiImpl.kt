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
    tags: Map<String, Any?>?,
    linkedId: String?,
    timeoutMs: Long?,
    callback: (Result<FingerprintNativeResult>) -> Unit,
  ) {
    // Keep JSON null values. The SDK type is Map<String, Any>, but the JVM
    // does not check it, so the Pigeon map is passed as is.
    // https://docs.fingerprint.com/docs/tagging-information
    @Suppress("UNCHECKED_CAST")
    val tagMap = (tags ?: emptyMap()) as Map<String, Any>
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
    // Pigeon catches throws only for sync methods like create. A throw here
    // reaches Flutter's message dispatcher, which:
    // - replies empty for an Exception, so Dart gets a channel-error without
    //   the SDK message
    // - rethrows an Error (e.g. UnsatisfiedLinkError on client creation),
    //   which crashes the app
    // https://github.com/flutter/flutter/blob/master/engine/src/flutter/shell/platform/android/io/flutter/embedding/engine/dart/DartMessenger.java
    // Wrap in FlutterError: other throwables reach Dart with the class name as code.
    try {
      val client = clientCache.getOrCreate(config)
      if (timeoutMs != null) {
        // Android getVisitorId takes Int. Long.toInt() wraps. Clamp so a huge timeout becomes Int.MAX_VALUE, not negative.
        // Dart rejects negative timeouts, so only the upper bound matters.
        val timeoutInt = timeoutMs.coerceAtMost(Int.MAX_VALUE.toLong()).toInt()
        client.getVisitorId(timeoutInt, tagMap, linked, listener, errorListener)
      } else {
        client.getVisitorId(tagMap, linked, listener, errorListener)
      }
    } catch (error: Throwable) {
      callback(Result.failure(FlutterError("unknown_error", error.toString())))
    }
  }
}
