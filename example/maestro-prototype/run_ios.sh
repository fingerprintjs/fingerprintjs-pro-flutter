#!/bin/bash
# Local Maestro experiment. Build the normal app and run it on a booted simulator.
set -euo pipefail

root=$(cd "$(dirname "$0")/../.." && pwd)
cd "$root"

maestro_bin=${MAESTRO_BIN:-maestro}
if ! command -v "$maestro_bin" >/dev/null && [ -x .local/maestro/maestro/bin/maestro ]; then
  maestro_bin="$root/.local/maestro/maestro/bin/maestro"
fi
if [ -z "${JAVA_HOME:-}" ]; then
  export JAVA_HOME=$(/usr/libexec/java_home -v 17)
fi

udid=${1:-}
if [ -z "$udid" ]; then
  udid=$(xcrun simctl list devices booted --json | python3 -c '
import json, sys
devices = [d for group in json.load(sys.stdin)["devices"].values() for d in group if d["state"] == "Booted"]
if len(devices) != 1:
    sys.exit("Boot one simulator, or pass its UDID as the first argument.")
print(devices[0]["udid"])
')
fi

results="$root/.local/maestro/results/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$results"
config_backup=$(mktemp)
cp example/.env.local "$config_backup"
trap 'cp "$config_backup" "$root/example/.env.local"; rm -f "$config_backup"' EXIT
python3 - <<'PY'
from pathlib import Path
config = Path('example/.env.local')
lines = [line for line in config.read_text().splitlines() if not line.startswith('DISABLE_LOCATION_COLLECTION=')]
config.write_text('\n'.join(lines) + '\nDISABLE_LOCATION_COLLECTION=true\n')
PY

(cd example && flutter build ios --simulator --debug --target=lib/main.dart)
cp "$config_backup" example/.env.local

app="$root/example/build/ios/iphonesimulator/Runner.app"
app_id=$(/usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' "$app/Info.plist")
xcrun simctl install "$udid" "$app"
"$maestro_bin" --device "$udid" test \
  -e APP_ID="$app_id" \
  --test-output-dir "$results" \
  --format JUNIT --output "$results/report.xml" \
  "$root/example/maestro-prototype/smoke.yaml"
