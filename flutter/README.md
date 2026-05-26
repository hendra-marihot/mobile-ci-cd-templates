# Flutter CI/CD Templates

Ready-to-use CI/CD configurations for Flutter projects targeting Android and iOS.

## Contents

### GitHub Actions
| Workflow | Trigger | Purpose |
|---|---|---|
| `analyze-test.yml` | push/PR to `main` | Format check, analyze, test with 80% coverage gate |
| `pr-checks.yml` | PR to `main`/`develop` | Parallel format, analyze, test, debug build |
| `build-deploy.yml` | push tag `v*` | Build signed AAB (Android) and unsigned iOS artifact |

### Codemagic
| Workflow | Trigger | Purpose |
|---|---|---|
| `android-release` | push tag `v*` | Test, build AAB, publish to Play Store internal |
| `flutter-test` | pull request | Analyze, format check, test with coverage |

### Fastlane
| Platform | Lane | Purpose |
|---|---|---|
| Android | `firebase_distribute` | Build APK and distribute via Firebase App Distribution |
| Android | `play_store_internal` | Build AAB and upload to Play Store internal track |
| iOS | `testflight_deploy` | Build IPA and upload to TestFlight |

### Scripts
| Script | Purpose |
|---|---|
| `check-coverage.sh` | Run tests and enforce a configurable coverage threshold |
| `build-runner.sh` | Run `build_runner` for code generation |

## Required Secrets

### Android
| Secret | Description |
|---|---|
| `KEYSTORE_BASE64` | Base64-encoded release keystore |
| `KEYSTORE_PASSWORD` | Keystore password |
| `KEY_ALIAS` | Key alias within the keystore |
| `KEY_PASSWORD` | Key password |

### Firebase / Play Store
| Secret | Description |
|---|---|
| `FIREBASE_APP_ID` | Firebase app ID for App Distribution |
| `PLAY_STORE_JSON_KEY` | Path to Play Store service account JSON |

## Setup

### 1. Copy workflow files

```bash
cp flutter/github-actions/*.yml .github/workflows/
```

### 2. Configure Android signing

Add a `key.properties` file (excluded from VCS) at the Android project root, or use environment variables decoded at build time. See `android/scripts/setup-signing.sh` for the environment-variable approach.

### 3. Set the Flutter version

All workflows pin to `flutter-version: '3.32.x'`. Update this to match your project's SDK constraint in `pubspec.yaml`.

## Coverage Check Usage

```bash
# Default 80% threshold
./scripts/check-coverage.sh

# Custom threshold
./scripts/check-coverage.sh 90
```
