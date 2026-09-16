#!/bin/bash
# Build the normal example app and run the shared Maestro smoke flow.
set -euo pipefail

root=$(cd "$(dirname "$0")/../.." && pwd)
cd "$root"
platform=${1:?Pass web, android, or ios}
maestro_bin=${MAESTRO_BIN:-maestro}
results="$root/.local/maestro/$platform"
mkdir -p "$results"
maestro_command=("$maestro_bin")
test_args=()
flow=mobile.yaml

case "$platform" in
  web)
    (cd example && flutter build web)
    url=http://127.0.0.1:3000
    # Refuse an occupied port instead of testing an unrelated server.
    python3 -c 'import socket; listener = socket.socket(); listener.bind(("127.0.0.1", 3000))'
    python3 -m http.server 3000 --bind 127.0.0.1 --directory example/build/web \
      > "$results/server.log" 2>&1 &
    server_pid=$!
    trap 'kill "$server_pid" 2>/dev/null || true' EXIT
    curl -fsS --retry 10 --retry-connrefused --retry-delay 1 "$url" > /dev/null
    flow=web.yaml
    test_args=(--headless -e "URL=$url")
    ;;
  android)
    device=${2:-emulator-5554}
    (cd example && flutter build apk --debug)
    adb -s "$device" install -r example/build/app/outputs/flutter-apk/app-debug.apk
    maestro_command+=(--device "$device")
    test_args=(-e APP_ID=com.fingerprintjs.flutter.fpjs_pro.fpjs_pro_plugin_example)
    ;;
  ios)
    device=${2:?Pass the booted simulator UDID as the second argument}
    (cd example && flutter build ios --simulator --debug)
    app=example/build/ios/iphonesimulator/Runner.app
    app_id=$(/usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' "$app/Info.plist")
    xcrun simctl install "$device" "$app"
    maestro_command+=(--device "$device")
    test_args=(-e "APP_ID=$app_id")
    ;;
  *)
    echo "Unknown platform: $platform" >&2
    exit 2
    ;;
esac

"${maestro_command[@]}" test "${test_args[@]}" \
  --test-output-dir "$results" --debug-output "$results" \
  --format JUNIT --output "$results/report.xml" \
  "$root/example/maestro/$flow"
