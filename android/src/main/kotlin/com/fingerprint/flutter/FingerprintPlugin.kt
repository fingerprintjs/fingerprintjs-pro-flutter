// Plugin entry point: registers the Pigeon host API on each Flutter engine.
// https://pub.dev/packages/pigeon
package com.fingerprint.flutter

import io.flutter.embedding.engine.plugins.FlutterPlugin

/** Registers the Pigeon [FingerprintHostApi] with the Flutter engine. */
class FingerprintPlugin : FlutterPlugin {
  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    FingerprintHostApi.setUp(binding.binaryMessenger, FingerprintHostApiImpl(binding.applicationContext))
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    FingerprintHostApi.setUp(binding.binaryMessenger, null)
  }
}
