package com.fingerprintjs.flutter.fpjs_pro.fpjs_pro_plugin

import android.content.Context
import androidx.annotation.NonNull
import com.fingerprintjs.android.fpjs_pro.Configuration
import com.fingerprintjs.android.fpjs_pro.FingerprintJS
import com.fingerprintjs.android.fpjs_pro.FingerprintJSFactory
import com.fingerprintjs.android.fpjs_pro.FingerprintJSProResponse
import com.fingerprintjs.android.fpjs_pro.Error
import com.fingerprintjs.android.fpjs_pro.ApiKeyRequired
import com.fingerprintjs.android.fpjs_pro.ApiKeyNotFound
import com.fingerprintjs.android.fpjs_pro.ApiKeyExpired
import com.fingerprintjs.android.fpjs_pro.RequestCannotBeParsed
import com.fingerprintjs.android.fpjs_pro.Failed
import com.fingerprintjs.android.fpjs_pro.RequestTimeout
import com.fingerprintjs.android.fpjs_pro.TooManyRequest
import com.fingerprintjs.android.fpjs_pro.OriginNotAvailable
import com.fingerprintjs.android.fpjs_pro.HeaderRestricted
import com.fingerprintjs.android.fpjs_pro.NotAvailableForCrawlBots
import com.fingerprintjs.android.fpjs_pro.NotAvailableWithoutUA
import com.fingerprintjs.android.fpjs_pro.WrongRegion
import com.fingerprintjs.android.fpjs_pro.SubscriptionNotActive
import com.fingerprintjs.android.fpjs_pro.UnsupportedVersion
import com.fingerprintjs.android.fpjs_pro.InstallationMethodRestricted
import com.fingerprintjs.android.fpjs_pro.ResponseCannotBeParsed
import com.fingerprintjs.android.fpjs_pro.NetworkError
import com.fingerprintjs.android.fpjs_pro.ClientTimeout
import com.fingerprintjs.android.fpjs_pro.UnknownError
import com.fingerprintjs.android.fpjs_pro.InvalidProxyIntegrationHeaders
import com.fingerprintjs.android.fpjs_pro.InvalidProxyIntegrationSecret
import com.fingerprintjs.android.fpjs_pro.ProxyIntegrationSecretEnvironmentMismatch

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FpjsProPlugin */
class FpjsProPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var applicationContext : Context
  private lateinit var fpjsClient : FingerprintJS

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "fpjs_pro_plugin")
    channel.setMethodCallHandler(this)
    applicationContext = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      INIT -> {
          val token = call.argument<String>("apiToken")
          if (token == null) {
            result.error("missing_argument", "Argument 'apiToken' is missing", null)
            return
          }

          val regionString = call.argument<String>("region")
          val endpoint = call.argument<String>("endpoint")
          val endpointFallbacks = call.argument<List<String>?>("endpointFallbacks")
          val region = regionString?.let { parseRegion(it) }
          val extendedResponseFormat = call.argument<Boolean>("extendedResponseFormat") ?: false
          val pluginVersion = call.argument<String>("pluginVersion") ?: "unknown"

          val allowUseOfLocationData = call.argument<Boolean>("allowUseOfLocationData") ?: false

          val locationTimeoutMillis = call.argument<Int>("locationTimeoutMillis") ?: 5000

          initFpjs(
              token,
              region,
              endpoint,
              endpointFallbacks,
              extendedResponseFormat,
              pluginVersion,
              allowUseOfLocationData,
              locationTimeoutMillis.toLong()
          )
          result.success("Successfully initialized FingerprintJS Pro Client")
        }
      GET_VISITOR_ID -> {
        val tags = call.argument<Map<String, Any>>("tags") ?: emptyMap()
        val linkedId = call.argument<String>("linkedId") ?: ""
        val timeoutMillis = call.argument<Int>("timeoutMs")
        getVisitorId(timeoutMillis, linkedId, tags, { visitorId ->
          result.success(visitorId)
        }, { errorCode, errorMessage ->
          result.error(errorCode, errorMessage, null)
        })
      }
      GET_VISITOR_DATA -> {
        val tags = call.argument<Map<String, Any>>("tags") ?: emptyMap()
        val linkedId = call.argument<String>("linkedId") ?: ""
        val timeoutMillis = call.argument<Int>("timeoutMs")
        getVisitorData(timeoutMillis, linkedId, tags, { getVisitorData ->
          result.success(getVisitorData)
        }, { errorCode, errorMessage ->
          result.error(errorCode, errorMessage, null)
        })
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

    private fun initFpjs(
        apiToken: String,
        region: Configuration.Region?,
        endpoint: String?,
        endpointFallbacks: List<String>?,
        extendedResponseFormat: Boolean,
        pluginVersion: String,
        allowUseOfLocationData: Boolean,
        locationTimeoutMillis: Long
    ) {
    val factory = FingerprintJSFactory(applicationContext)
    val configuration = Configuration(
      apiToken,
      region ?: Configuration.Region.US,
      endpoint ?: region?.endpointUrl ?: Configuration.Region.US.endpointUrl,
      extendedResponseFormat,
      endpointFallbacks ?: emptyList(),
      listOf(Pair("fingerprint-pro-flutter", pluginVersion)),
      allowUseOfLocationData,
      locationTimeoutMillis,
    )

    fpjsClient = factory.createInstance(configuration)
  }

  private fun getVisitorId(
    timeoutMillis: Int?,
    linkedId: String,
    tags: Map<String, Any>,
    listener: (String) -> Unit,
    errorListener: (String, String) -> (Unit)
  ) {
    if (timeoutMillis != null) {
      fpjsClient.getVisitorId(
        timeoutMillis,
        tags,
        linkedId,
        listener = { result -> listener(result.visitorId) },
        errorListener = { error -> errorListener(getErrorCode(error), error.description.toString()) }
      )
    } else {
      fpjsClient.getVisitorId(
        tags,
        linkedId,
        listener = { result -> listener(result.visitorId) },
        errorListener = { error -> errorListener(getErrorCode(error), error.description.toString()) }
      )
    }
  }

  private fun getVisitorData(
    timeoutMillis: Int?,
    linkedId: String,
    tags: Map<String, Any>,
    listener: (List<Any>) -> Unit,
    errorListener: (String, String) -> (Unit)
  ) {
    if (timeoutMillis != null) {
      fpjsClient.getVisitorId(
        timeoutMillis,
        tags,
        linkedId,
        listener = {result -> listener(listOf(result.requestId, result.confidenceScore.score, result.asJson, result.sealedResult ?: ""))},
        errorListener = { error -> errorListener(getErrorCode(error), error.description.toString())}
      )
    } else {
      fpjsClient.getVisitorId(
        tags,
        linkedId,
        listener = {result -> listener(listOf(result.requestId, result.confidenceScore.score, result.asJson, result.sealedResult ?: ""))},
        errorListener = { error -> errorListener(getErrorCode(error), error.description.toString())}
      )
    }
  }
}

fun parseRegion(region: String): Configuration.Region {
  return when (region.lowercase()) {
    "eu" -> Configuration.Region.EU
    "us" -> Configuration.Region.US
    "ap" -> Configuration.Region.AP
    else -> throw IllegalArgumentException("Invalid region: $region")
  }
}

const val INIT = "init"
const val GET_VISITOR_ID = "getVisitorId"
const val GET_VISITOR_DATA = "getVisitorData"

private fun getErrorCode(error: Error): String {
  val errorType = when(error) {
    is ApiKeyRequired -> "ApiKeyRequired"
    is ApiKeyNotFound ->  "ApiKeyNotFound"
    is ApiKeyExpired -> "ApiKeyExpired"
    is RequestCannotBeParsed -> "RequestCannotBeParsed"
    is Failed -> "Failed"
    is RequestTimeout -> "RequestTimeout"
    is TooManyRequest -> "TooManyRequest"
    is OriginNotAvailable -> "OriginNotAvailable"
    is HeaderRestricted -> "HeaderRestricted"
    is NotAvailableForCrawlBots -> "NotAvailableForCrawlBots"
    is NotAvailableWithoutUA -> "NotAvailableWithoutUA"
    is WrongRegion -> "WrongRegion"
    is SubscriptionNotActive -> "SubscriptionNotActive"
    is UnsupportedVersion -> "UnsupportedVersion"
    is InstallationMethodRestricted -> "InstallationMethodRestricted"
    is ResponseCannotBeParsed -> "ResponseCannotBeParsed"
    is NetworkError -> "NetworkError"
    is ClientTimeout -> "ClientTimeout"
    is InvalidProxyIntegrationHeaders -> "InvalidProxyIntegrationHeaders"
    is InvalidProxyIntegrationSecret -> "InvalidProxyIntegrationSecret"
    is ProxyIntegrationSecretEnvironmentMismatch -> "ProxyIntegrationSecretEnvironmentMismatch"
    else -> "UnknownError"
  }
  return errorType
}
