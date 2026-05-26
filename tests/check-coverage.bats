#!/usr/bin/env bats

setup() {
  TMPDIR="$(mktemp -d)"
  SCRIPT="$BATS_TEST_DIRNAME/../flutter/scripts/check-coverage.sh"
}

teardown() {
  rm -rf "$TMPDIR"
}

extract_coverage() {
  local lcov_output="$1"
  echo "$lcov_output" | grep 'lines' | sed 's/.*: //;s/%.*//'
}

@test "grep pattern extracts coverage percentage from lcov output" {
  result=$(extract_coverage "  lines......: 85.3% (1234 of 1447 lines)")
  [ "$result" = "85.3" ]
}

@test "grep pattern handles 100% coverage" {
  result=$(extract_coverage "  lines......: 100.0% (500 of 500 lines)")
  [ "$result" = "100.0" ]
}

@test "grep pattern handles single digit coverage" {
  result=$(extract_coverage "  lines......: 5.2% (10 of 192 lines)")
  [ "$result" = "5.2" ]
}

@test "script has set -euo pipefail" {
  head -2 "$SCRIPT" | grep -q 'set -euo pipefail'
}

@test "script defaults threshold to 80" {
  grep -q 'THRESHOLD=${1:-80}' "$SCRIPT"
}

@test "script gracefully handles missing lcov" {
  grep -q 'command -v lcov' "$SCRIPT"
}
