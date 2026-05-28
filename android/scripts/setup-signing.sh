#!/bin/bash
set -euo pipefail

for var in KEYSTORE_BASE64 KEYSTORE_PASSWORD KEY_ALIAS KEY_PASSWORD; do
  if [ -z "${!var:-}" ]; then
    echo "Error: $var environment variable is not set"
    exit 1
  fi
done

# Signing material is secret: restrict permissions so the keystore and the
# plaintext passwords in signing.properties are not group/world-readable on
# shared CI runners. umask covers newly created files; chmod covers the case
# where the target files already existed (`>` truncates but keeps old perms).
umask 077

echo "$KEYSTORE_BASE64" | base64 --decode > app/release.keystore

cat > app/signing.properties << EOF
storeFile=release.keystore
storePassword=${KEYSTORE_PASSWORD}
keyAlias=${KEY_ALIAS}
keyPassword=${KEY_PASSWORD}
EOF

chmod 600 app/release.keystore app/signing.properties

echo "Signing configuration created successfully"
