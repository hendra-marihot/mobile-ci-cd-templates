#!/usr/bin/env bats

setup() {
  ROOT="$BATS_TEST_DIRNAME/.."
}

@test "all shell scripts have set -euo pipefail" {
  for f in "$ROOT"/android/scripts/*.sh \
           "$ROOT"/flutter/scripts/*.sh \
           "$ROOT"/shared/scripts/*.sh; do
    head -2 "$f" | grep -q 'set -euo pipefail'
  done
}

@test "all shell scripts are executable" {
  for f in "$ROOT"/android/scripts/*.sh \
           "$ROOT"/flutter/scripts/*.sh \
           "$ROOT"/shared/scripts/*.sh; do
    [ -x "$f" ]
  done
}

@test "no hardcoded secrets in scripts" {
  for f in "$ROOT"/android/scripts/*.sh \
           "$ROOT"/flutter/scripts/*.sh \
           "$ROOT"/shared/scripts/*.sh; do
    ! grep -qiE '(password|secret|token)\s*=\s*["\x27][a-zA-Z0-9]' "$f"
  done
}

@test "scripts use env vars for credentials" {
  grep -q 'KEYSTORE_BASE64' "$ROOT/android/scripts/setup-signing.sh"
  grep -q 'KEYSTORE_PASSWORD' "$ROOT/android/scripts/setup-signing.sh"
  grep -q 'KEY_ALIAS' "$ROOT/android/scripts/setup-signing.sh"
  grep -q 'KEY_PASSWORD' "$ROOT/android/scripts/setup-signing.sh"
}

@test "version-bump.sh uses portable grep (no -oP)" {
  ! grep -q 'grep -oP' "$ROOT/android/scripts/version-bump.sh"
}

@test "version-bump.sh uses portable sed (no -i without backup)" {
  ! grep -qE "sed -i [^']" "$ROOT/android/scripts/version-bump.sh"
}

@test "check-coverage.sh uses portable grep (no -oP)" {
  ! grep -q 'grep -oP' "$ROOT/flutter/scripts/check-coverage.sh"
}

@test "Matchfile is in ios directory, not android" {
  [ ! -f "$ROOT/android/fastlane/Matchfile" ]
  [ -f "$ROOT/ios/fastlane/Matchfile" ]
}

@test "placeholder uses com.yourcompany.yourapp" {
  grep -q 'com.yourcompany.yourapp' "$ROOT/android/fastlane/Appfile"
  grep -q 'com.yourcompany.yourapp' "$ROOT/flutter/fastlane/Appfile"
}
