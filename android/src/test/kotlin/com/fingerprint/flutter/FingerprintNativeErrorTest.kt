package com.fingerprint.flutter

import com.fingerprint.android.ApiKeyRequired
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
}
