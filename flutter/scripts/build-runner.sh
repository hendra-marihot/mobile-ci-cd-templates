#!/bin/bash
set -euo pipefail

echo "Running build_runner..."
dart run build_runner build --delete-conflicting-outputs
echo "Code generation complete"
