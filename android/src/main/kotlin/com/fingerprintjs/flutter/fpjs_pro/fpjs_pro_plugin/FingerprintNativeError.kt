// Maps com.fingerprint.android.Error to Pigeon FlutterError codes (snake_case).
// Match on type, not javaClass.simpleName. R8 can rename classes in minified
// builds, which would send the wrong Dart code.
// https://developer.android.com/build/shrink-code
package com.fingerprintjs.flutter.fpjs_pro.fpjs_pro_plugin

import com.fingerprint.android.ApiKeyNotFound
import com.fingerprint.android.ApiKeyRequired
import com.fingerprint.android.ClientTimeout
import com.fingerprint.android.EnvironmentRestricted
import com.fingerprint.android.Error
import com.fingerprint.android.Failed
import com.fingerprint.android.FeatureNotEnabled
import com.fingerprint.android.InstallationMethodRestricted
import com.fingerprint.android.InvalidProxyIntegrationHeaders
import com.fingerprint.android.InvalidProxyIntegrationSecret
import com.fingerprint.android.MissingModule
import com.fingerprint.android.NetworkError
import com.fingerprint.android.NetworkUnavailableError
import com.fingerprint.android.PayloadTooLarge
import com.fingerprint.android.ProxyIntegrationSecretEnvironmentMismatch
import com.fingerprint.android.RequestCannotBeParsed
import com.fingerprint.android.RequestTimeout
import com.fingerprint.android.ResponseCannotBeParsed
import com.fingerprint.android.ServiceUnavailable
import com.fingerprint.android.SubscriptionNotActive
import com.fingerprint.android.SubscriptionRestricted
import com.fingerprint.android.TooManyRequest
import com.fingerprint.android.UnknownError
import com.fingerprint.android.VisitorNotFound
import com.fingerprint.android.WrongRegion

internal fun errorCode(error: Error): String = when (error) {
  is Failed -> "failed"
  is RequestCannotBeParsed -> "request_cannot_be_parsed"
  is RequestTimeout -> "request_read_timeout" // API code, not class name request_timeout
  is TooManyRequest -> "too_many_requests"
  is ApiKeyRequired -> "public_api_key_required"
  is ApiKeyNotFound -> "public_api_key_not_found"
  is SubscriptionNotActive -> "subscription_not_active"
  is SubscriptionRestricted -> "subscription_restricted"
  is WrongRegion -> "wrong_region"
  is FeatureNotEnabled -> "feature_not_enabled"
  is VisitorNotFound -> "visitor_not_found"
  is MissingModule -> "missing_module"
  is PayloadTooLarge -> "payload_too_large"
  is ServiceUnavailable -> "service_unavailable"
  is EnvironmentRestricted -> "environment_restricted"
  is InstallationMethodRestricted -> "installation_method_restricted"
  is InvalidProxyIntegrationSecret -> "invalid_proxy_integration_secret"
  is InvalidProxyIntegrationHeaders -> "invalid_proxy_integration_headers"
  is ProxyIntegrationSecretEnvironmentMismatch ->
    "proxy_integration_secret_environment_mismatch"
  is ResponseCannotBeParsed -> "response_cannot_be_parsed"
  // Android splits offline vs request failure. iOS and web use one code.
  is NetworkError -> "network_error"
  is NetworkUnavailableError -> "network_error"
  is ClientTimeout -> "client_timeout"
  is UnknownError -> "unknown_error"
  else -> "unknown_error"
}

internal fun normalizeEventId(eventId: String?): String? {
  // Android Error defaults eventId to "Unknown" when the SDK has no id.
  // That is not a server event. Empty and missing are also not usable ids.
  if (eventId == null || eventId.isEmpty() || eventId == "Unknown") {
    return null
  }
  return eventId
}

internal fun normalizeMessage(description: String?): String? {
  // Same Android default as eventId. Do not forward "Unknown" as a message.
  if (description == null || description == "Unknown") {
    return null
  }
  return description
}

internal fun toFlutterError(error: Error): FlutterError {
  val eventId = normalizeEventId(error.eventId)
  val message = normalizeMessage(error.description)
  return FlutterError(errorCode(error), message, eventId)
}
