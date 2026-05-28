#!/bin/bash
set -euo pipefail

BUMP_TYPE=${1:-patch}
GRADLE_FILE=${GRADLE_FILE:-app/build.gradle.kts}

CURRENT_CODE=$(grep -oE 'versionCode = [0-9]+' "$GRADLE_FILE" | grep -oE '[0-9]+$' || true)
CURRENT_NAME=$(grep -oE 'versionName = "[^"]+"' "$GRADLE_FILE" | sed 's/versionName = "//;s/"$//' || true)

if [ -z "$CURRENT_CODE" ]; then
  echo "Error: could not find 'versionCode = <int>' in $GRADLE_FILE"
  exit 1
fi
if [[ ! "$CURRENT_NAME" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: versionName '$CURRENT_NAME' is not in major.minor.patch form in $GRADLE_FILE"
  exit 1
fi

NEW_CODE=$((CURRENT_CODE + 1))

IFS='.' read -r major minor patch <<< "$CURRENT_NAME"
case "$BUMP_TYPE" in
  major) NEW_NAME="$((major + 1)).0.0" ;;
  minor) NEW_NAME="${major}.$((minor + 1)).0" ;;
  patch) NEW_NAME="${major}.${minor}.$((patch + 1))" ;;
  *) echo "Usage: $0 [major|minor|patch]"; exit 1 ;;
esac

sed "s/versionCode = $CURRENT_CODE/versionCode = $NEW_CODE/" "$GRADLE_FILE" > "$GRADLE_FILE.tmp" && mv "$GRADLE_FILE.tmp" "$GRADLE_FILE"
sed "s/versionName = \"$CURRENT_NAME\"/versionName = \"$NEW_NAME\"/" "$GRADLE_FILE" > "$GRADLE_FILE.tmp" && mv "$GRADLE_FILE.tmp" "$GRADLE_FILE"

echo "Version bumped: $CURRENT_NAME ($CURRENT_CODE) -> $NEW_NAME ($NEW_CODE)"
