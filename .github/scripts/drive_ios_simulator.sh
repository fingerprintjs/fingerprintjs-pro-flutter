#!/bin/sh
# Runs the smoke test on a booted iOS simulator. Run from `example/` after
# `flutter build ios --simulator --target=integration_test/smoke_test.dart`.
#
# Left to itself, `flutter drive` installs and launches the app and then finds the Dart VM
# service URL by scraping the simulator log. It starts `simctl log stream` without waiting
# for it to attach, so when the app prints the URL first the line is lost and the tool waits
# forever, with no output after "Xcode build done" (flutter#181771). Launching the app here
# on a fixed port with auth codes off makes the URL known up front, so `flutter drive`
# connects to it directly and never reads the log.
set -eu

udid=$1
app=build/ios/iphonesimulator/Runner.app
port=8181
vm_service="http://127.0.0.1:$port/"

bundle_id=$(/usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' "$app/Info.plist")
xcrun simctl install "$udid" "$app"
# The flags `flutter drive` passes to a debug simulator app, plus the fixed port and no auth code.
xcrun simctl launch "$udid" "$bundle_id" \
  --enable-dart-profiling --enable-checked-mode --verify-entry-points \
  --vm-service-port="$port" --disable-service-auth-codes

# The test starts as soon as the app launches; `flutter drive` collects the result afterwards.
# A healthy launch answers within seconds. Give up well before the step timeout so a crash on
# launch fails fast, with the simulator log dumped by the next step.
attempts=0
until curl -sf "${vm_service}getVersion" > /dev/null; do
  attempts=$((attempts + 1))
  if [ "$attempts" -ge 60 ]; then
    echo "::error::Dart VM service did not come up on $vm_service within 2 minutes"
    exit 1
  fi
  sleep 2
done

flutter drive \
  --use-existing-app="$vm_service" \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/smoke_test.dart \
  -d "$udid"
