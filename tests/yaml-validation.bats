#!/usr/bin/env bats

setup() {
  ROOT="$BATS_TEST_DIRNAME/.."
}

@test "all YAML files are syntactically valid" {
  run yamllint -d "{extends: relaxed, rules: {line-length: {max: 200}}}" \
    "$ROOT"/android/github-actions/*.yml \
    "$ROOT"/flutter/github-actions/*.yml \
    "$ROOT"/flutter/codemagic/*.yaml \
    "$ROOT"/shared/github-actions/*.yml
  [ "$status" -eq 0 ]
}

@test "CI workflows have concurrency groups" {
  for f in "$ROOT"/android/github-actions/build-test.yml \
           "$ROOT"/flutter/github-actions/analyze-test.yml \
           "$ROOT"/android/github-actions/pr-checks.yml \
           "$ROOT"/flutter/github-actions/pr-checks.yml; do
    grep -q 'concurrency:' "$f"
  done
}

@test "all workflows declare permissions" {
  for f in "$ROOT"/android/github-actions/*.yml \
           "$ROOT"/flutter/github-actions/*.yml \
           "$ROOT"/shared/github-actions/*.yml; do
    grep -q 'permissions:' "$f"
  done
}

@test "no hardcoded secrets in workflows" {
  for f in "$ROOT"/android/github-actions/*.yml \
           "$ROOT"/flutter/github-actions/*.yml \
           "$ROOT"/shared/github-actions/*.yml; do
    ! grep -qiE '(password|secret|token|key)\s*[:=]\s*["\x27][^${\x27"]' "$f"
  done
}

@test "actions use pinned versions" {
  for f in "$ROOT"/android/github-actions/*.yml \
           "$ROOT"/flutter/github-actions/*.yml; do
    ! grep -qE 'uses: .+@(main|master)\b' "$f"
  done
}

@test "no com.example.app placeholder remains" {
  run grep -r 'com\.example\.app' "$ROOT" --include='*.yml' --include='*.yaml'
  [ "$status" -ne 0 ]
}

@test "semantic-release has releasable commit guard" {
  grep -q 'should_release' "$ROOT/shared/github-actions/semantic-release.yml"
}
