@TestOn('browser')
library;

import 'dart:js_interop';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpjs_pro_plugin/error.dart';
import 'package:fpjs_pro_plugin/fingerprint_web.dart';
import 'package:fpjs_pro_plugin/js_agent_interop.dart';
import 'package:fpjs_pro_plugin/web_result.dart';

/// Builds what the JS agent returns. A missing sealed result has no key at all.
IdentificationResult _identificationResult({String? sealedResult}) {
  return {
    'requestId': 'test_request_id',
    'visitorId': 'test_visitor_id',
    'confidence': {'score': 0.09},
    'sealedResult': ?sealedResult,
  }.jsify() as IdentificationResult;
}

void main() {
  group('fromJsObject', () {
    test('keeps a sealed result', () {
      final result = FingerprintJSProResponseWeb.fromJsObject(
          _identificationResult(sealedResult: 'test_sealed_result'));
      expect(result.sealedResult, 'test_sealed_result');
    });

    // The native platforms send an empty string, so web must not surface the
    // agent's missing value as null.
    test('normalizes a missing sealed result', () {
      final result =
          FingerprintJSProResponseWeb.fromJsObject(_identificationResult());
      expect(result.sealedResult, '');
    });
  });

  group('errors complete the future', () {
    test('getVisitorId before init', () async {
      await expectLater(
          FingerprintWeb().getVisitorId(), throwsA(isA<FingerprintProError>()));
    });

    test('getVisitorData before init', () async {
      await expectLater(FingerprintWeb().getVisitorData(),
          throwsA(isA<FingerprintProError>()));
    });
  });
}
