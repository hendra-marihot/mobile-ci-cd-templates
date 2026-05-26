#!/bin/bash
set -euo pipefail

for var in KEYSTORE_BASE64 KEYSTORE_PASSWORD KEY_ALIAS KEY_PASSWORD; do
  if [ -z "${!var:-}" ]; then
    echo "Error: $var environment variable is not set"
    exit 1
  fi
done

echo "$KEYSTORE_BASE64" | base64 --decode > app/release.keystore

cat > app/signing.properties << EOF
storeFile=release.keystore
storePassword=${KEYSTORE_PASSWORD}
keyAlias=${KEY_ALIAS}
keyPassword=${KEY_PASSWORD}
EOF

echo "Signing configuration created successfully"
