// This is a CLI entry point; prints are the interface, as in the upstream
// `integrationDriver` this replaces.
// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:integration_test/common.dart';
import 'package:integration_test/integration_test_driver.dart';

/// The framework takes a `SemanticsHandle` of its own as soon as the platform
/// turns accessibility on, and `testWidgets` records the handle count before the
/// test body runs. CI simulators and emulators turn accessibility on at an
/// unpredictable moment, so when it lands mid-test the end-of-test check finds one
/// handle more than the baseline and fails a test whose assertions all passed
/// (https://github.com/flutter/flutter/issues/153850). On an iOS simulator this
/// happened in roughly 40% of runs.
///
/// The smoke test takes no semantics handles itself, so a run reporting only this
/// is never a plugin failure. If the smoke test ever does take one, this tolerance
/// has to go, because it would then hide a real leak.
const semanticsHandleRaceAssertion =
    'A SemanticsHandle was active at the end of the test.';

/// Whether [response] reports the semantics handle race and nothing else.
///
/// `failureDetails` is null rather than empty for a response that carries no
/// failures at all, such as a web driver command, so an empty list must not
/// count as "every failure is tolerable".
bool reportsOnlySemanticsHandleRace(Response response) {
  if (response.allTestsPassed) return false;
  final failures = response.failureDetails ?? const <Failure>[];
  return failures.isNotEmpty &&
      failures.every(
        (failure) =>
            failure.details?.contains(semanticsHandleRaceAssertion) ?? false,
      );
}

Future<void> main() async {
  final driver = await FlutterDriver.connect();
  final result = await driver.requestData(
    null,
    timeout: const Duration(minutes: 20),
  );
  final response = Response.fromJson(result);
  await driver.close();

  if (response.allTestsPassed) {
    print('All tests passed.');
    await writeResponseData(response.data);
    exit(0);
  }

  print('Failure details:\n${response.formattedFailureDetails}');

  if (reportsOnlySemanticsHandleRace(response)) {
    print(
      'Passing anyway: the only failure is the platform semantics handle race, '
      'which the smoke flow itself completed in spite of.',
    );
    // Written on this path too, so a tolerated run leaves the same artifacts as
    // a clean one.
    await writeResponseData(response.data);
    exit(0);
  }

  exit(1);
}
