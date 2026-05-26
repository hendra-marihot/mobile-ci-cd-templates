#!/usr/bin/env bats

setup() {
  SCRIPT="$BATS_TEST_DIRNAME/../shared/scripts/changelog-generator.sh"
  TMPDIR="$(mktemp -d)"
  cd "$TMPDIR"
  git init --quiet
  git config user.email "test@test.com"
  git config user.name "Test"
  echo "init" > file.txt
  git add file.txt
  git commit --quiet -m "feat: initial commit"
  git tag v0.1.0
}

teardown() {
  cd /
  rm -rf "$TMPDIR"
}

@test "outputs changelog header" {
  echo "change" > file2.txt && git add file2.txt
  git commit --quiet -m "feat: add feature"
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"# Changelog"* ]]
}

@test "lists feat commits under Features" {
  echo "change" > file2.txt && git add file2.txt
  git commit --quiet -m "feat: add new button"
  run bash "$SCRIPT"
  [[ "$output" == *"### Features"* ]]
  [[ "$output" == *"feat: add new button"* ]]
}

@test "lists fix commits under Bug Fixes" {
  echo "change" > file2.txt && git add file2.txt
  git commit --quiet -m "fix: resolve crash on startup"
  run bash "$SCRIPT"
  [[ "$output" == *"### Bug Fixes"* ]]
  [[ "$output" == *"fix: resolve crash on startup"* ]]
}

@test "shows changes since last tag" {
  echo "change" > file2.txt && git add file2.txt
  git commit --quiet -m "feat: after tag"
  run bash "$SCRIPT"
  [[ "$output" == *"Changes since v0.1.0"* ]]
}

@test "script has set -euo pipefail" {
  head -2 "$SCRIPT" | grep -q 'set -euo pipefail'
}
