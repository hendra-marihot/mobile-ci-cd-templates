#!/bin/bash
set -euo pipefail

THRESHOLD=${1:-80}

flutter test --coverage

if ! command -v lcov &> /dev/null; then
  echo "lcov not found, skipping threshold check"
  exit 0
fi

COVERAGE=$(lcov --summary coverage/lcov.info 2>&1 | grep 'lines' | sed 's/.*: //;s/%.*//')
echo "Line coverage: ${COVERAGE}%"

if awk "BEGIN {exit !($COVERAGE < $THRESHOLD)}"; then
  echo "FAIL: Coverage ${COVERAGE}% is below threshold ${THRESHOLD}%"
  exit 1
fi

echo "PASS: Coverage ${COVERAGE}% meets threshold ${THRESHOLD}%"
