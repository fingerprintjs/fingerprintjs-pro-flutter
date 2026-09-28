package com.fingerprintjs.flutter.fpjs_pro.fpjs_pro_plugin

import com.fingerprint.android.ApiKeyRequired
import com.fingerprint.android.StateNotReady
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class FingerprintNativeErrorTest {
  @Test
  fun stripsUnknownEventIdAndDescription() {
    val flutterError = toFlutterError(ApiKeyRequired("Unknown", "Unknown"))
    assertEquals("public_api_key_required", flutterError.code)
    assertNull(flutterError.message)
    assertNull(flutterError.details)
  }

  @Test
  fun keepsRealEventIdInDetails() {
    val flutterError = toFlutterError(ApiKeyRequired("evt-123", "need key"))
    assertEquals("public_api_key_required", flutterError.code)
    assertEquals("need key", flutterError.message)
    assertEquals("evt-123", flutterError.details)
  }

  @Test
  fun forwardsUnmappedErrorAsUnknownWithDescription() {
    val flutterError = toFlutterError(StateNotReady("evt-1", "state not ready"))
    assertEquals("unknown_error", flutterError.code)
    assertEquals("state not ready", flutterError.message)
    assertEquals("evt-1", flutterError.details)
  }

  @Test
  fun namesUnmappedErrorTypeWhenDescriptionIsMissing() {
    val flutterError = toFlutterError(StateNotReady("Unknown", "Unknown"))
    assertEquals("unknown_error", flutterError.code)
    assertEquals("StateNotReady", flutterError.message)
  }
}
