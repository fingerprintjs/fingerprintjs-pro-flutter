#!/bin/sh
# Runs a command, retrying it once. The smoke flow makes a dozen live identification
# calls, so a single transient network error should not fail the run. Two failures in
# a row still fail.
set -u

"$@" && exit 0
echo "::warning::smoke test attempt failed, retrying once"
exec "$@"
