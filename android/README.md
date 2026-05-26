# Android CI/CD Templates

Ready-to-use CI/CD configurations for Android projects using Gradle and Kotlin.

## Contents

### GitHub Actions
| Workflow | Trigger | Purpose |
|---|---|---|
| `build-test.yml` | push/PR to `main` | Run unit tests, lint, build debug APK |
| `pr-checks.yml` | PR to `main`/`develop` | Parallel lint, test, build gates |
| `release-play-store.yml` | push tag `v*` | Sign AAB and upload to Play Store internal track |

### Fastlane
| File | Purpose |
|---|---|
| `Fastfile` | `test`, `build_debug`, `deploy_internal`, `promote_to_production` lanes |
| `Appfile` | Package name + Play Store JSON key path |

### Scripts
| Script | Purpose |
|---|---|
| `setup-signing.sh` | Decode base64 keystore and write `signing.properties` |
| `version-bump.sh` | Bump `versionCode` and `versionName` in `build.gradle.kts` |

## Required Secrets

| Secret | Description |
|---|---|
| `KEYSTORE_BASE64` | Base64-encoded release keystore file |
| `KEYSTORE_PASSWORD` | Keystore password |
| `KEY_ALIAS` | Key alias within the keystore |
| `KEY_PASSWORD` | Key password |
| `PLAY_STORE_SERVICE_ACCOUNT` | Play Store service account JSON (plain text) |

## Setup

### 1. Configure signing in `app/build.gradle.kts`

```kotlin
android {
    signingConfigs {
        create("release") {
            val props = java.util.Properties()
            val signingFile = rootProject.file("app/signing.properties")
            if (signingFile.exists()) props.load(signingFile.inputStream())
            storeFile = props.getProperty("storeFile")?.let { file(it) }
            storePassword = props.getProperty("storePassword")
            keyAlias = props.getProperty("keyAlias")
            keyPassword = props.getProperty("keyPassword")
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

### 2. Copy workflow files

```bash
cp android/github-actions/*.yml .github/workflows/
```

### 3. Add secrets to GitHub repository

Go to **Settings > Secrets and variables > Actions** and add all required secrets.

## Version Bump Usage

```bash
# Bump patch: 1.0.0 -> 1.0.1
./scripts/version-bump.sh patch

# Bump minor: 1.0.1 -> 1.1.0
./scripts/version-bump.sh minor

# Bump major: 1.1.0 -> 2.0.0
./scripts/version-bump.sh major
```
