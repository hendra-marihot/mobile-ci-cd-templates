#!/usr/bin/env bats

setup() {
  SCRIPT="$BATS_TEST_DIRNAME/../android/scripts/setup-signing.sh"
  TMPDIR="$(mktemp -d)"
  mkdir -p "$TMPDIR/app"
  cd "$TMPDIR"
}

teardown() {
  cd /
  rm -rf "$TMPDIR"
}

@test "fails when KEYSTORE_BASE64 is not set" {
  unset KEYSTORE_BASE64 KEYSTORE_PASSWORD KEY_ALIAS KEY_PASSWORD
  run bash "$SCRIPT"
  [ "$status" -ne 0 ]
  [[ "$output" == *"KEYSTORE_BASE64"* ]]
}

@test "fails when KEYSTORE_PASSWORD is not set" {
  export KEYSTORE_BASE64="dGVzdA=="
  unset KEYSTORE_PASSWORD KEY_ALIAS KEY_PASSWORD
  run bash "$SCRIPT"
  [ "$status" -ne 0 ]
  [[ "$output" == *"KEYSTORE_PASSWORD"* ]]
}

@test "fails when KEY_ALIAS is not set" {
  export KEYSTORE_BASE64="dGVzdA=="
  export KEYSTORE_PASSWORD="pass"
  unset KEY_ALIAS KEY_PASSWORD
  run bash "$SCRIPT"
  [ "$status" -ne 0 ]
  [[ "$output" == *"KEY_ALIAS"* ]]
}

@test "fails when KEY_PASSWORD is not set" {
  export KEYSTORE_BASE64="dGVzdA=="
  export KEYSTORE_PASSWORD="pass"
  export KEY_ALIAS="alias"
  unset KEY_PASSWORD
  run bash "$SCRIPT"
  [ "$status" -ne 0 ]
  [[ "$output" == *"KEY_PASSWORD"* ]]
}

@test "creates keystore and signing.properties with all vars set" {
  export KEYSTORE_BASE64="dGVzdGtleXN0b3Jl"
  export KEYSTORE_PASSWORD="storepass"
  export KEY_ALIAS="myalias"
  export KEY_PASSWORD="keypass"
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [ -f "app/release.keystore" ]
  [ -f "app/signing.properties" ]
}

@test "signing.properties contains correct values" {
  export KEYSTORE_BASE64="dGVzdGtleXN0b3Jl"
  export KEYSTORE_PASSWORD="storepass"
  export KEY_ALIAS="myalias"
  export KEY_PASSWORD="keypass"
  bash "$SCRIPT"
  grep -q 'storeFile=release.keystore' app/signing.properties
  grep -q 'storePassword=storepass' app/signing.properties
  grep -q 'keyAlias=myalias' app/signing.properties
  grep -q 'keyPassword=keypass' app/signing.properties
}

@test "secret files are owner-only (not group/world readable)" {
  export KEYSTORE_BASE64="dGVzdGtleXN0b3Jl"
  export KEYSTORE_PASSWORD="storepass"
  export KEY_ALIAS="myalias"
  export KEY_PASSWORD="keypass"
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  # GNU stat (Linux CI) then BSD stat (macOS) fallback.
  perms=$(stat -c '%a' app/signing.properties 2>/dev/null || stat -f '%Lp' app/signing.properties)
  [ "$perms" = "600" ]
  perms=$(stat -c '%a' app/release.keystore 2>/dev/null || stat -f '%Lp' app/release.keystore)
  [ "$perms" = "600" ]
}

@test "keystore is correctly decoded from base64" {
  export KEYSTORE_BASE64="$(echo -n 'hello keystore' | base64)"
  export KEYSTORE_PASSWORD="pass"
  export KEY_ALIAS="alias"
  export KEY_PASSWORD="pass"
  bash "$SCRIPT"
  [ "$(cat app/release.keystore)" = "hello keystore" ]
}
