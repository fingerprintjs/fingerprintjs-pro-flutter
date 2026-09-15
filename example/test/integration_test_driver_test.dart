import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/common.dart';

import '../test_driver/integration_test.dart';

// The exact payload an iOS simulator produced when accessibility turned on
// while the smoke flow was running. Every assertion in the flow had passed.
const _semanticsRaceDetails = '''
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞═════════════════
The following assertion was thrown running a test:
A SemanticsHandle was active at the end of the test.
All SemanticsHandle instances must be disposed by calling
dispose() on the SemanticsHandle.

When the exception was thrown, this was the stack:
#0      WidgetTester._verifySemanticsHandlesWereDisposed (package:flutter_test/src/widget_tester.dart:1074:7)
''';

const _realFailureDetails = '''
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞═════════════════
The following TestFailure was thrown running a test:
Failed waiting for a device ID: Failed to get device id: UnknownError: too many requests
''';

void main() {
  group('reportsOnlySemanticsHandleRace', () {
    test('tolerates a run whose only failure is the semantics race', () {
      final response = Response.someTestsFailed(<Failure>[
        Failure('runs the example app smoke flow', _semanticsRaceDetails),
      ]);

      expect(reportsOnlySemanticsHandleRace(response), isTrue);
    });

    test('does not tolerate a real failure alongside the race', () {
      final response = Response.someTestsFailed(<Failure>[
        Failure('runs the example app smoke flow', _semanticsRaceDetails),
        Failure('runs the example app smoke flow', _realFailureDetails),
      ]);

      expect(reportsOnlySemanticsHandleRace(response), isFalse);
    });

    test('does not tolerate a real failure on its own', () {
      final response = Response.someTestsFailed(<Failure>[
        Failure('runs the example app smoke flow', _realFailureDetails),
      ]);

      expect(reportsOnlySemanticsHandleRace(response), isFalse);
    });

    test('does not tolerate a failure that carries no details', () {
      final response = Response.someTestsFailed(<Failure>[
        Failure('runs the example app smoke flow', null),
      ]);

      expect(reportsOnlySemanticsHandleRace(response), isFalse);
    });

    test('does not tolerate an empty failure list', () {
      final response = Response.someTestsFailed(<Failure>[]);

      expect(reportsOnlySemanticsHandleRace(response), isFalse);
    });

    // A failed web driver command reports no failures at all. Treating that as
    // "every failure is tolerable" would turn the web job green on any crash.
    test('does not tolerate a web driver command response', () {
      expect(reportsOnlySemanticsHandleRace(Response.webDriverCommand()), isFalse);
    });

    test('reports nothing to tolerate when the run passed', () {
      expect(reportsOnlySemanticsHandleRace(Response.allTestsPassed()), isFalse);
    });

    // Guards the whole mechanism: the tolerance matches on the assertion text, so
    // it silently stops working if that text stops arriving in `details`.
    test('matches the assertion text the framework actually emits', () {
      expect(_semanticsRaceDetails, contains(semanticsHandleRaceAssertion));
    });
  });
}
