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
  bash "$SCRIPT" patch
  grep -q 'versionCode = 43' "$GRADLE_FILE"
  grep -q 'versionName = "1.2.4"' "$GRADLE_FILE"
}

@test "minor bump increments minor version and resets patch" {
  bash "$SCRIPT" minor
  grep -q 'versionCode = 43' "$GRADLE_FILE"
  grep -q 'versionName = "1.3.0"' "$GRADLE_FILE"
}

@test "major bump increments major version and resets minor and patch" {
  bash "$SCRIPT" major
  grep -q 'versionCode = 43' "$GRADLE_FILE"
  grep -q 'versionName = "2.0.0"' "$GRADLE_FILE"
}

@test "default bump type is patch" {
  bash "$SCRIPT"
  grep -q 'versionName = "1.2.4"' "$GRADLE_FILE"
}

@test "versionCode always increments by 1" {
  bash "$SCRIPT" patch
  bash "$SCRIPT" patch
  grep -q 'versionCode = 44' "$GRADLE_FILE"
  grep -q 'versionName = "1.2.5"' "$GRADLE_FILE"
}

@test "preserves other gradle file content" {
  bash "$SCRIPT" patch
  grep -q 'android {' "$GRADLE_FILE"
  grep -q 'defaultConfig {' "$GRADLE_FILE"
}
