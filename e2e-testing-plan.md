# E2E testing plan

## Goal

Add the simplest possible automated check that matches the current manual verification flow:

1. Run the example app.
2. Click **Run tests!**.
3. Verify the checks pass.
4. Click **Identify!**.
5. Verify a visitor ID is returned.
6. Inspect the extended agent response enough to confirm it is available.

The initial version should run on every pull request for web, Android, and iOS.

## Scope

The first iteration should validate that the Flutter plugin is wired correctly across all supported platforms. It should not attempt to deeply validate Fingerprint backend behavior.

Assertions should stay intentionally small and stable:

- the example app starts successfully;
- **Run tests!** eventually changes the checks result to `Success!`;
- **Identify!** eventually renders a non-empty device ID that is not `Unknown` and does not start with `Failed`;
- **Identify with extended result!** opens the extended result dialog and shows a response containing expected top-level fields such as `visitorId` or `requestId`.

## Implementation approach

Use Flutter's official `integration_test` package against the existing `example` app.

Keep the app interaction close to the manual process:

- add stable widget keys to the existing buttons and result labels;
- create one integration test that taps the same controls a maintainer taps manually;
- wait for success/result text instead of asserting exact visitor IDs or exact response payloads;
- avoid new test frameworks unless Flutter `integration_test` cannot cover a required interaction.

## CI approach

Add a pull request workflow that runs the same integration test on:

- web using Chrome;
- Android using an emulator;
- iOS using a simulator on macOS.

The workflow should create `example/.env.local` from GitHub secrets before running the app. Required configuration:

- `API_KEY`;
- `REGION`, if the test workspace is not in the default region;
- `ENDPOINT` and `SCRIPT_URL_PATTERN`, only if required by the test workspace.

Because the repository is public, secret-backed E2E jobs need an explicit policy for forked pull requests. If secrets are unavailable, the workflow should skip the live-service E2E jobs rather than fail unrelated external contributions.

## Recommended first PR contents

1. Add `integration_test` to the example app.
2. Add widget keys to the existing example app controls/results.
3. Add one integration test for the manual smoke flow.
4. Add a GitHub Actions workflow that runs the test on web, Android, and iOS for pull requests when secrets are available.
5. Document the required secrets and local command for running the test manually.

## Follow-ups

After the smoke test is stable, consider adding targeted checks for linked IDs, tags, timeout behavior, and platform-specific permission behavior. These should be separate follow-ups so the first automated E2E check remains simple.
