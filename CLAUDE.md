# Mobile CI/CD Templates

## Project Overview

A reference collection of production-grade CI/CD configurations for Android and Flutter
mobile projects. The purpose is to eliminate repetitive setup on new projects — copy
the files you need, fill in the placeholder values, and ship.

**This is a templates repository, not an application.** There is no build system,
no test runner, no package manager for the repo itself. Do not run `./gradlew`,
`flutter pub get`, or any project-level build command against this repo.

## Repository Structure

```
mobile-ci-cd-templates/
├── .github/workflows/
│   └── ci.yml                      # Meta-CI: shellcheck + yamllint + BATS tests on PRs
├── android/
│   ├── github-actions/
│   │   ├── build-test.yml          # CI: test + lint + debug APK on push/PR to main
│   │   ├── pr-checks.yml           # PR gate: parallel lint, test, build
│   │   └── release-play-store.yml  # CD: signed AAB → Play Store internal on tag
│   ├── fastlane/
│   │   ├── Fastfile                # test, build_debug, deploy_internal, promote_to_production lanes
│   │   └── Appfile                 # package name + Play Store JSON key path
│   └── scripts/
│       ├── setup-signing.sh        # decode base64 keystore, write signing.properties
│       └── version-bump.sh         # bump versionCode + versionName in build.gradle.kts
├── flutter/
│   ├── github-actions/
│   │   ├── analyze-test.yml        # CI: format + analyze + test with 80% coverage gate
│   │   ├── pr-checks.yml           # PR gate: format, analyze, test, debug APK build
│   │   └── build-deploy.yml        # CD: signed AAB + unsigned iOS artifact on tag
│   ├── codemagic/
│   │   └── codemagic.yaml          # Android release + PR test workflow for Codemagic
│   ├── fastlane/
│   │   ├── Fastfile                # firebase_distribute, play_store_internal, testflight_deploy
│   │   └── Appfile                 # package name + Play Store key path
│   └── scripts/
│       ├── check-coverage.sh       # flutter test --coverage + configurable threshold
│       └── build-runner.sh         # dart run build_runner build --delete-conflicting-outputs
├── ios/
│   └── fastlane/
│       └── Matchfile               # Match config for iOS code signing
├── shared/
│   ├── github-actions/
│   │   └── semantic-release.yml    # auto-tag + GitHub Release from Conventional Commits
│   └── scripts/
│       └── changelog-generator.sh  # print feat/fix/other commits since last tag
└── tests/                          # BATS test suites for template validation
```

## Editing Conventions

### Shell Scripts

- All scripts use `set -euo pipefail` on line 2. Never remove this.
- All scripts in this repo must be executable (`chmod +x`). Verify with `ls -l`.
- No hardcoded secrets. Use environment variables referenced as `${VAR_NAME}`.
- Use POSIX-compatible commands only: `grep -oE` (not `-oP`), temp-file `sed` (not `sed -i`).
- Scripts that hardcode paths should accept env var overrides for testability
  (e.g., `GRADLE_FILE=${GRADLE_FILE:-app/build.gradle.kts}`).

### GitHub Actions Workflows

- Use action versions: `actions/checkout@v4`, `actions/setup-java@v4`,
  `actions/cache@v4`, `actions/upload-artifact@v4`.
- CI workflows (not PR-only) must include a `concurrency` group with
  `cancel-in-progress: true` to avoid redundant runs.
- All workflows must declare explicit `permissions:` blocks (least privilege).
- YAML must be valid. Check with a YAML linter before committing.

### Fastlane

- No hardcoded secrets. Use `ENV["VAR_NAME"]` for all credentials.
- Android `Appfile` and Flutter `Appfile` both use `com.yourcompany.yourapp` as the
  package name. This is a placeholder — replace when adapting for a real project.

### Placeholder Values

`com.yourcompany.yourapp` is used throughout as the application package name. When
adapting a template for a real project, search all copied files for this string and
replace it.

## Secrets Reference

### Android GitHub Actions

| Secret | Description |
|---|---|
| `KEYSTORE_BASE64` | `base64 -i release.keystore` output |
| `KEYSTORE_PASSWORD` | Keystore password |
| `KEY_ALIAS` | Key alias (`keytool -list -v -keystore release.keystore`) |
| `KEY_PASSWORD` | Key password |
| `PLAY_STORE_SERVICE_ACCOUNT` | Service account JSON content (plain text) |

### Flutter GitHub Actions

Same as Android above, plus:

| Secret | Description |
|---|---|
| `FIREBASE_APP_ID` | Firebase App Distribution app ID (for Fastlane lane) |
| `PLAY_STORE_JSON_KEY` | Path to Play Store service account JSON (for Fastlane lane) |

### Codemagic

| Variable group | Variable | Description |
|---|---|---|
| `android_signing` | `CM_KEYSTORE` | Base64-encoded keystore |
| `android_signing` | `CM_KEYSTORE_PASSWORD` | Keystore password |
| `android_signing` | `CM_KEY_ALIAS` | Key alias |
| `android_signing` | `CM_KEY_PASSWORD` | Key password |
| `google_play_credentials` | `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS` | Service account JSON |

## Validation Checklist Before Committing Changes

Run all three checks before committing:
```bash
shellcheck android/scripts/*.sh flutter/scripts/*.sh shared/scripts/*.sh
yamllint -d "{extends: relaxed, rules: {line-length: {max: 200}}}" android/github-actions/*.yml flutter/github-actions/*.yml flutter/codemagic/*.yaml shared/github-actions/*.yml
bats tests/
```

- [ ] Shell scripts are executable (`ls -l scripts/`)
- [ ] No secrets or real credentials appear in any file
- [ ] YAML files pass a linter
- [ ] `set -euo pipefail` present in every `.sh` file
- [ ] Placeholder `com.yourcompany.yourapp` is documented clearly in any consumer-facing docs
- [ ] All BATS tests pass (`bats tests/`)

## Testing

Tests use [BATS](https://github.com/bats-core/bats-core) (Bash Automated Testing System).
Tests MUST invoke the actual script under test — never inline a copy of the script logic.
Use env var overrides to point scripts at temp fixtures (see `tests/version-bump.bats`).
