package com.fingerprintjs.flutter.fpjs_pro.fpjs_pro_plugin

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin

/** Registers the Pigeon [FingerprintHostApi] with the Flutter engine. */
class FpjsProPlugin : FlutterPlugin {
  private var hostApiImpl: FingerprintHostApiImpl? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    hostApiImpl = FingerprintHostApiImpl(flutterPluginBinding.applicationContext)
    FingerprintHostApi.setUp(flutterPluginBinding.binaryMessenger, hostApiImpl)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    FingerprintHostApi.setUp(binding.binaryMessenger, null)
    hostApiImpl = null
  }
}
