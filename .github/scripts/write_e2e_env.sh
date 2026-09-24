#!/bin/sh
# Writes example/.env.local for the E2E smoke test from the job's environment.
# Set DISABLE_LOCATION_COLLECTION=true on native platforms, where a permission
# dialog would otherwise block an unattended run.
set -eu

# GitHub sets a missing secret to the empty string, which would otherwise reach the app
# as an empty key and fail much later, in the middle of the smoke flow.
[ -n "$API_KEY" ] || { echo "API_KEY is empty"; exit 1; }

target=example/.env.local

printf 'API_KEY=%s\n' "$API_KEY" > "$target"
[ -z "${REGION:-}" ] || printf 'REGION=%s\n' "$REGION" >> "$target"
[ -z "${ENDPOINTS:-}" ] || printf 'ENDPOINTS=%s\n' "$ENDPOINTS" >> "$target"
[ -z "${SCRIPT_URL_PATTERN:-}" ] \
  || printf 'SCRIPT_URL_PATTERN=%s\n' "$SCRIPT_URL_PATTERN" >> "$target"
[ "${DISABLE_LOCATION_COLLECTION:-false}" != true ] \
  || printf 'DISABLE_LOCATION_COLLECTION=true\n' >> "$target"
