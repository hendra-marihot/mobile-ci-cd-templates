#!/usr/bin/env bats

setup() {
  SCRIPT="$BATS_TEST_DIRNAME/../android/scripts/version-bump.sh"
  TMPDIR="$(mktemp -d)"
  mkdir -p "$TMPDIR/app"
  export GRADLE_FILE="$TMPDIR/app/build.gradle.kts"
  cat > "$GRADLE_FILE" << 'GRADLE'
android {
    defaultConfig {
        versionCode = 42
        versionName = "1.2.3"
    }
}
GRADLE
}

teardown() {
  rm -rf "$TMPDIR"
}

@test "patch bump increments patch version and versionCode" {
  run bash "$SCRIPT" patch
  [ "$status" -eq 0 ]
  grep -q 'versionCode = 43' "$GRADLE_FILE"
  grep -q 'versionName = "1.2.4"' "$GRADLE_FILE"
}

@test "minor bump increments minor version and resets patch" {
  run bash "$SCRIPT" minor
  [ "$status" -eq 0 ]
  grep -q 'versionCode = 43' "$GRADLE_FILE"
  grep -q 'versionName = "1.3.0"' "$GRADLE_FILE"
}

@test "major bump increments major version and resets minor and patch" {
  run bash "$SCRIPT" major
  [ "$status" -eq 0 ]
  grep -q 'versionCode = 43' "$GRADLE_FILE"
  grep -q 'versionName = "2.0.0"' "$GRADLE_FILE"
}

@test "default bump type is patch" {
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  grep -q 'versionName = "1.2.4"' "$GRADLE_FILE"
}

@test "versionCode always increments by 1" {
  run bash "$SCRIPT" patch
  [ "$status" -eq 0 ]
  run bash "$SCRIPT" patch
  [ "$status" -eq 0 ]
  grep -q 'versionCode = 44' "$GRADLE_FILE"
  grep -q 'versionName = "1.2.5"' "$GRADLE_FILE"
}

@test "preserves other gradle file content" {
  run bash "$SCRIPT" patch
  [ "$status" -eq 0 ]
  grep -q 'android {' "$GRADLE_FILE"
  grep -q 'defaultConfig {' "$GRADLE_FILE"
}

@test "rejects an invalid bump type" {
  run bash "$SCRIPT" bogus
  [ "$status" -ne 0 ]
  [[ "$output" == *"Usage"* ]]
}

@test "fails with a clear message when versionCode is missing" {
  cat > "$GRADLE_FILE" << 'GRADLE'
android { defaultConfig { versionName = "1.0.0" } }
GRADLE
  run bash "$SCRIPT" patch
  [ "$status" -ne 0 ]
  [[ "$output" == *"versionCode"* ]]
}

@test "fails with a clear message when versionName is not major.minor.patch" {
  cat > "$GRADLE_FILE" << 'GRADLE'
android { defaultConfig { versionCode = 7
        versionName = "1.2.3-beta" } }
GRADLE
  run bash "$SCRIPT" patch
  [ "$status" -ne 0 ]
  [[ "$output" == *"major.minor.patch"* ]]
}
