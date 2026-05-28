#!/usr/bin/env bats

setup() {
  SCRIPT="$BATS_TEST_DIRNAME/../flutter/scripts/check-coverage.sh"
  STUBS="$(mktemp -d)"
  # flutter is stubbed to a no-op success so the script proceeds to the gate.
  printf '#!/bin/bash\nexit 0\n' > "$STUBS/flutter"
  chmod +x "$STUBS/flutter"
}

teardown() {
  rm -rf "$STUBS"
}

# Stub lcov to emit a given "lines" summary value so we exercise the real
# parsing + threshold logic in check-coverage.sh (never reimplement it here).
stub_lcov_lines() {
  printf '#!/bin/bash\necho "  lines......: %s"\n' "$1" > "$STUBS/lcov"
  chmod +x "$STUBS/lcov"
}

@test "passes when line coverage meets the threshold" {
  stub_lcov_lines "85.3% (1234 of 1447 lines)"
  PATH="$STUBS:/usr/bin:/bin" run bash "$SCRIPT" 80
  [ "$status" -eq 0 ]
  [[ "$output" == *"PASS: Coverage 85.3%"* ]]
}

@test "fails when line coverage is below the threshold" {
  stub_lcov_lines "12.5% (1 of 8 lines)"
  PATH="$STUBS:/usr/bin:/bin" run bash "$SCRIPT" 80
  [ "$status" -eq 1 ]
  [[ "$output" == *"FAIL: Coverage 12.5%"* ]]
}

@test "respects a custom threshold argument" {
  stub_lcov_lines "85.0% (85 of 100 lines)"
  PATH="$STUBS:/usr/bin:/bin" run bash "$SCRIPT" 90
  [ "$status" -eq 1 ]
  [[ "$output" == *"FAIL"* ]]
}

@test "fails closed (never PASS) when coverage value is non-numeric" {
  stub_lcov_lines "N/A%"
  PATH="$STUBS:/usr/bin:/bin" run bash "$SCRIPT" 80
  [ "$status" -ne 0 ]
  [[ "$output" != *"PASS"* ]]
  [[ "$output" == *"could not parse"* ]]
}

@test "fails closed when lcov output has no lines row" {
  printf '#!/bin/bash\necho "  functions..: 90.0%%"\n' > "$STUBS/lcov"
  chmod +x "$STUBS/lcov"
  PATH="$STUBS:/usr/bin:/bin" run bash "$SCRIPT" 80
  [ "$status" -ne 0 ]
  [[ "$output" != *"PASS"* ]]
}

@test "skips the gate when lcov is not installed" {
  # No lcov stub created; /usr/bin and /bin do not provide lcov on the test host.
  PATH="$STUBS:/usr/bin:/bin" run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"lcov not found"* ]]
}

@test "script has set -euo pipefail" {
  head -2 "$SCRIPT" | grep -q 'set -euo pipefail'
}

@test "script defaults threshold to 80" {
  grep -q 'THRESHOLD=${1:-80}' "$SCRIPT"
}
