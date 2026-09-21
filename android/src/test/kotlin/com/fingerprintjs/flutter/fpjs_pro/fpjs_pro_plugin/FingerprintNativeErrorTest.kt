package com.fingerprintjs.flutter.fpjs_pro.fpjs_pro_plugin

import com.fingerprint.android.ApiKeyRequired
import com.fingerprint.android.Failed
import com.fingerprint.android.RequestTimeout
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class FingerprintNativeErrorTest {
  @Test
  fun mapsErrorTypesByInstanceNotSimpleName() {
    assertEquals("public_api_key_required", errorCode(ApiKeyRequired("e1", "msg")))
    assertEquals("failed", errorCode(Failed("e2", "fail")))
    assertEquals("request_read_timeout", errorCode(RequestTimeout("e3", "timeout")))
  }

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
