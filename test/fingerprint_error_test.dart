import 'package:flutter_test/flutter_test.dart';
import 'package:fpjs_pro_plugin/src/fingerprint_error.dart';

/// Every raw code the v4 platforms can report, listed independently of the
/// matrix under test so a member deleted from the enum fails a test instead of
/// silently degrading to [FingerprintErrorCode.unknown].
///
/// Sources, all v4: the `Error` subclasses in `com.fingerprint.android` and the
/// server keys its error factory maps to them, the `FPError` cases and
/// `APIError.Code` raw values in the iOS SDK's module interface, and the web
/// agent's `ERROR_CODE_*` constants.
///
/// The codes are the API's error keys, so an entry here is the key behind the
/// native type rather than the native type's own name. They differ in two
/// places, both on Android: the class `RequestTimeout` comes from
/// `request_read_timeout`, and `RequestNotFound` from `event_not_found`.
const _rawCodesByPlatform = {
  'android': [
    'failed',
    'request_cannot_be_parsed',
    'request_read_timeout',
    'response_cannot_be_parsed',
    'too_many_requests',
    'public_api_key_required',
    'public_api_key_not_found',
    'secret_api_key_required',
    'secret_api_key_not_found',
    'subscription_not_active',
    'subscription_not_found',
    'subscription_restricted',
    'wrong_region',
    'feature_not_enabled',
    'visitor_not_found',
    'event_not_found',
    'missing_module',
    'payload_too_large',
    'service_unavailable',
    'state_not_ready',
    'ruleset_not_found',
    'environment_restricted',
    'installation_method_restricted',
    'invalid_proxy_integration_secret',
    'invalid_proxy_integration_headers',
    'proxy_integration_secret_environment_mismatch',
    'network_error',
    'network_unavailable',
    'client_timeout',
    'unknown_error',
  ],
  'ios': [
    'failed',
    'request_cannot_be_parsed',
    'request_read_timeout',
    'too_many_requests',
    'public_api_key_required',
    'public_api_key_not_found',
    'secret_api_key_required',
    'secret_api_key_not_found',
    'subscription_not_active',
    'subscription_not_found',
    'subscription_restricted',
    'wrong_region',
    'feature_not_enabled',
    'visitor_not_found',
    'event_not_found',
    'missing_module',
    'payload_too_large',
    'service_unavailable',
    'state_not_ready',
    'ruleset_not_found',
    'environment_restricted',
    'installation_method_restricted',
    'invalid_proxy_integration_secret',
    'invalid_proxy_integration_headers',
    'proxy_integration_secret_environment_mismatch',
    'invalid_url',
    'invalid_url_params',
    'network_error',
    'json_parsing_error',
    'invalid_response_type',
    'client_timeout',
    'unknown_error',
  ],
  'web': [
    'failed',
    'request_cannot_be_parsed',
    'request_read_timeout',
    'too_many_requests',
    'public_api_key_required',
    'public_api_key_not_found',
    'secret_api_key_required',
    'secret_api_key_not_found',
    'subscription_not_active',
    'wrong_region',
    'feature_not_enabled',
    'visitor_not_found',
    'event_not_found',
    'request_not_found',
    'missing_module',
    'payload_too_large',
    'state_not_ready',
    'sandboxed_iframe',
    'client_timeout',
    'network_connection',
    'network_abort',
    'csp_block',
    'invalid_endpoint',
    'handle_agent_data',
    'script_load_fail',
    'bundle_not_defined',
    'bad_response_format',
    'server_error',
    'api_key_missing',
    'api_key_invalid',
    'cache_misconfigured',
    'endpoints_misconfigured',
    'wrong_worker_option',
    'worker_initialization_failed',
  ],
};

void main() {
  group('FingerprintErrorCode', () {
    _rawCodesByPlatform.forEach((platform, rawCodes) {
      test('maps every $platform raw code to a code of its own', () {
        final unmapped = rawCodes
            .where((rawCode) =>
                FingerprintErrorCode.fromRawCode(rawCode) ==
                FingerprintErrorCode.unknown)
            // `unknown_error` is the one raw code that belongs on `unknown`.
            .where((rawCode) => rawCode != 'unknown_error')
            .toList();
        expect(unmapped, isEmpty,
            reason: 'These $platform codes are missing from the matrix');
      });
    });

    test('covers every raw code the platforms can report and nothing else', () {
      final reported = {
        for (final rawCodes in _rawCodesByPlatform.values) ...rawCodes
      };
      final mapped =
          FingerprintErrorCode.values.map((code) => code.rawCode).toSet();
      expect(mapped.difference(reported), isEmpty,
          reason: 'The matrix lists codes no platform reports');
      expect(reported.difference(mapped), isEmpty,
          reason: 'The platforms report codes the matrix is missing');
    });

    test('maps a code newer than the matrix to unknown', () {
      expect(FingerprintErrorCode.fromRawCode('some_future_code'),
          FingerprintErrorCode.unknown);
    });

    test('maps the iOS camelCase leak to unknown rather than guessing', () {
      // The iOS `APIError.Code` enum has no raw values, so its `@unknown
      // default` arm reports the camelCase case name. Nothing in the matrix
      // claims those, on purpose: a code the native side failed to map is
      // unknown to us too, and `rawCode` still carries it.
      expect(FingerprintErrorCode.fromRawCode('tooManyRequests'),
          FingerprintErrorCode.unknown);
    });

    test('maps unknown_error to unknown', () {
      expect(FingerprintErrorCode.fromRawCode('unknown_error'),
          FingerprintErrorCode.unknown);
    });

    test('uses snake_case raw codes throughout, as v4 does', () {
      for (final code in FingerprintErrorCode.values) {
        expect(code.rawCode, matches(RegExp(r'^[a-z][a-z0-9_]*$')),
            reason: '${code.name} has a raw code that is not snake_case');
      }
    });

    test('gives every member a distinct raw code', () {
      final rawCodes =
          FingerprintErrorCode.values.map((code) => code.rawCode).toList();
      expect(rawCodes.toSet(), hasLength(rawCodes.length));
    });
  });

  group('FingerprintError', () {
    test('keeps the code, message and event id it was given', () {
      final error = FingerprintError(
          rawCode: 'too_many_requests',
          message: 'Too many requests',
          eventId: 'event-1');

      expect(error.code, FingerprintErrorCode.tooManyRequests);
      expect(error.rawCode, 'too_many_requests');
      expect(error.message, 'Too many requests');
      expect(error.eventId, 'event-1');
    });

    test('keeps an unmapped raw code while reporting unknown', () {
      final error = FingerprintError(rawCode: 'some_future_code');

      expect(error.code, FingerprintErrorCode.unknown);
      expect(error.rawCode, 'some_future_code');
    });

    test('treats an empty raw code as unknown_error, since it says nothing',
        () {
      final error = FingerprintError(rawCode: '');

      expect(error.code, FingerprintErrorCode.unknown);
      expect(error.rawCode, 'unknown_error');
    });

    test('normalizes an absent message to null', () {
      expect(FingerprintError(rawCode: 'failed').message, isNull);
      // Android sends an empty description rather than omitting it.
      expect(FingerprintError(rawCode: 'failed', message: '').message, isNull);
    });

    test('normalizes an absent event id to null', () {
      expect(FingerprintError(rawCode: 'failed').eventId, isNull);
      expect(FingerprintError(rawCode: 'failed', eventId: '').eventId, isNull);
    });

    test('normalizes the Android Unknown event id sentinel to null', () {
      // Android reports this when the failure never reached the server.
      expect(FingerprintError(rawCode: 'network_error', eventId: 'Unknown')
          .eventId,
          isNull);
    });

    test('does not mistake a real event id for the sentinel', () {
      expect(
          FingerprintError(rawCode: 'failed', eventId: 'Unknown-1').eventId,
          'Unknown-1');
    });

    test('is an Exception, so it can be thrown and caught as one', () {
      expect(FingerprintError(rawCode: 'failed'), isA<Exception>());
      expect(() => throw FingerprintError(rawCode: 'failed'),
          throwsA(isA<FingerprintError>()));
    });

    test('names the raw code, the message and the event id in toString', () {
      expect(
          FingerprintError(
                  rawCode: 'too_many_requests',
                  message: 'Too many requests',
                  eventId: 'event-1')
              .toString(),
          'FingerprintError(too_many_requests, Too many requests, '
          'eventId: event-1)');
    });

    test('leaves out what it does not have in toString', () {
      expect(FingerprintError(rawCode: 'client_timeout').toString(),
          'FingerprintError(client_timeout)');
    });

    test('FingerprintError.unknown builds a codeless failure', () {
      final error = FingerprintError.unknown('the agent rejected with a string');

      expect(error.code, FingerprintErrorCode.unknown);
      expect(error.rawCode, 'unknown_error');
      expect(error.message, 'the agent rejected with a string');
      expect(error.eventId, isNull);
    });

    test('FingerprintError.unknown takes no message at all', () {
      expect(FingerprintError.unknown().message, isNull);
    });
  });
}
