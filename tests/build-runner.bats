#!/usr/bin/env bats

setup() {
  SCRIPT="$BATS_TEST_DIRNAME/../flutter/scripts/build-runner.sh"
  STUBS="$(mktemp -d)"
  ARGS_FILE="$STUBS/dart-args"
}

teardown() {
  rm -rf "$STUBS"
}

@test "invokes dart build_runner with --delete-conflicting-outputs" {
  # Stub dart to record the args the script passes to it.
  cat > "$STUBS/dart" << EOF
#!/bin/bash
echo "\$@" > "$ARGS_FILE"
EOF
  chmod +x "$STUBS/dart"
  PATH="$STUBS:/usr/bin:/bin" run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Code generation complete"* ]]
  [ "$(cat "$ARGS_FILE")" = "run build_runner build --delete-conflicting-outputs" ]
}

@test "fails when dart is not available" {
  # No dart stub on PATH; /usr/bin and /bin do not provide dart on the test host.
  # Direct negation (no `run`) keeps this portable across all bats versions.
  ! PATH="$STUBS:/usr/bin:/bin" bash "$SCRIPT"
}

@test "script has set -euo pipefail" {
  head -2 "$SCRIPT" | grep -q 'set -euo pipefail'
}
