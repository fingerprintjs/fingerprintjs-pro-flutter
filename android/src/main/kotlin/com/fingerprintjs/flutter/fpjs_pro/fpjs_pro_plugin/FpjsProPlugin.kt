package com.fingerprintjs.flutter.fpjs_pro.fpjs_pro_plugin

import android.content.Context
import androidx.annotation.NonNull
import com.fingerprintjs.android.fpjs_pro.Configuration
import com.fingerprintjs.android.fpjs_pro.FingerprintJS
import com.fingerprintjs.android.fpjs_pro.FingerprintJSFactory
import com.fingerprintjs.android.fpjs_pro.FingerprintJSProResponse

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
          val region = regionString?.let { parseRegion(it) }
          val extendedResponseFormat = call.argument<Boolean>("extendedResponseFormat") ?: false

          initFpjs(token, region, endpoint, extendedResponseFormat)
          result.success("Successfully initialized FingerprintJS Pro Client")
        }
      GET_VISITOR_ID -> {
          val tags = call.argument<Map<String, Any>>("tags") ?: emptyMap()
          val linkedId = call.argument<String>("linkedId") ?: ""
          getVisitorId(linkedId, tags, {
                visitorId -> result.success(visitorId)
            }, {
                errorMessage -> result.error("fpjs_error", errorMessage, null)
            })
          }
      GET_VISITOR_DATA -> {
        val tags = call.argument<Map<String, Any>>("tags") ?: emptyMap()
        val linkedId = call.argument<String>("linkedId") ?: ""
        getVisitorData(linkedId, tags, {
            getVisitorData -> result.success(getVisitorData)
        }, {
            errorMessage -> result.error("fpjs_error", errorMessage, null)
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

  private fun initFpjs(apiToken: String, region: Configuration.Region?, endpoint: String?, extendedResponseFormat: Boolean) {
    val factory = FingerprintJSFactory(applicationContext)
    val configuration = Configuration(apiToken, region ?: Configuration.Region.US, endpoint ?: region?.endpointUrl ?: Configuration.Region.US.endpointUrl, extendedResponseFormat)

    fpjsClient = factory.createInstance(configuration)
  }

  private fun getVisitorId(
    linkedId: String,
    tags: Map<String, Any>,
    listener: (String) -> Unit,
    errorListener: (String) -> (Unit)
  ) {
    fpjsClient.getVisitorId(
      tags,
      linkedId,
      listener = {result -> listener(result.visitorId)},
      errorListener = {error -> errorListener(error.description.toString())}
    )
  }

  private fun getVisitorData(
    linkedId: String,
    tags: Map<String, Any>,
    listener: (List<Any>) -> Unit,
    errorListener: (String) -> (Unit)
  ) {
    fpjsClient.getVisitorId(
      tags,
      linkedId,
      listener = {result -> listener(Triple(result.requestId, result.confidenceScore.score, result.asJson).toList())},
      errorListener = {error -> errorListener(error.description.toString())}
    )
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