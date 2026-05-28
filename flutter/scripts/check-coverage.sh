#!/bin/bash
set -euo pipefail

THRESHOLD=${1:-80}

flutter test --coverage

if ! command -v lcov &> /dev/null; then
  echo "lcov not found, skipping threshold check"
  exit 0
fi

COVERAGE=$(lcov --summary coverage/lcov.info 2>&1 | grep 'lines' | sed 's/.*: //;s/%.*//' || true)

# Guard against a missing/changed lcov format: an empty or non-numeric value
# would make the awk comparison error out and the gate silently fail open.
if [[ ! "$COVERAGE" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
  echo "Error: could not parse line coverage from lcov output (got: '${COVERAGE}')"
  exit 1
fi

echo "Line coverage: ${COVERAGE}%"

if awk "BEGIN {exit !($COVERAGE < $THRESHOLD)}"; then
  echo "FAIL: Coverage ${COVERAGE}% is below threshold ${THRESHOLD}%"
  exit 1
fi

echo "PASS: Coverage ${COVERAGE}% meets threshold ${THRESHOLD}%"
