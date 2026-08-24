#!/usr/bin/env bash
# Fail if the default Wasm dry run reports Dart-to-JS interop casts in this
# plugin. `flutter build web --wasm` still succeeds for those casts; they crash
# at runtime on dart2wasm (https://github.com/fingerprintjs/fingerprintjs-pro-flutter/issues/137).
# Convert with `.toJS`: https://dart.dev/interop/js-interop/start
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root/example"

if [[ ! -f .env.local ]]; then
  cp .env .env.local
fi

log="$(mktemp)"
trap 'rm -f "$log"' EXIT

flutter build web 2>&1 | tee "$log"

# Dry-run also warns on `e is WebException`. Those are a different class of
# check and are left as warnings so a List→JSArray fix can go green on its own.
if grep -E 'fpjs_pro_plugin_web\.dart .+invalid_runtime_check_with_js_interop_types lint violation: Cast from .+ casts a Dart value to a JS interop type' "$log"; then
  echo
  echo "error: Dart-to-JS interop casts in fpjs_pro_plugin_web.dart are incompatible with Flutter WASM."
  echo "See https://github.com/fingerprintjs/fingerprintjs-pro-flutter/issues/137"
  exit 1
fi
