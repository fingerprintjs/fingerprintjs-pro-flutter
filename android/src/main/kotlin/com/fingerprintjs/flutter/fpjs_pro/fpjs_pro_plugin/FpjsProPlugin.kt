package com.fingerprintjs.flutter.fpjs_pro.fpjs_pro_plugin

import android.content.Context
import androidx.annotation.NonNull
import com.fingerprintjs.android.fpjs_pro.Configuration
import com.fingerprintjs.android.fpjs_pro.FPJSProClient
import com.fingerprintjs.android.fpjs_pro.FPJSProFactory

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
  private lateinit var fpjsClient : FPJSProClient

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

          initFpjs(token, region, endpoint)
          result.success("Successfully initialized FingerprintJS Pro Client")
        }
      GET_VISITOR_ID -> {
          val tags = call.argument<Map<String, Any>>("tags") ?: emptyMap()
          getVisitorId(tags, {
                visitorId -> result.success(visitorId)
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

  private fun initFpjs(apiToken: String, region: Configuration.Region?, endpoint: String?) {
    val factory = FPJSProFactory(applicationContext)
    val configuration = Configuration(apiToken, region ?: Configuration.Region.US, endpoint ?: Configuration.Region.US.endpointUrl)

    fpjsClient = factory.createInstance(configuration)
  }

  private fun getVisitorId(
    tags: Map<String, Any>,
    listener: (String) -> Unit,
    errorListener: (String) -> (Unit)
  ) {
    fpjsClient.getVisitorId(tags, listener, errorListener)
  }
}

fun parseRegion(region: String): Configuration.Region {
  return when (region.lowercase()) {
    "eu" -> Configuration.Region.EU
    "us" -> Configuration.Region.US
    else -> throw IllegalArgumentException("Invalid region: $region")
  }
}

const val INIT = "init"
const val GET_VISITOR_ID = "getVisitorId"