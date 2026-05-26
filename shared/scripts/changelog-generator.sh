#!/bin/bash
set -euo pipefail

LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || git rev-list --max-parents=0 HEAD)

echo "# Changelog"
echo ""
echo "## Changes since $LAST_TAG"
echo ""

echo "### Features"
git log "$LAST_TAG"..HEAD --pretty="- %s (%h)" --grep="^feat" || echo "- None"
echo ""

echo "### Bug Fixes"
git log "$LAST_TAG"..HEAD --pretty="- %s (%h)" --grep="^fix" || echo "- None"
echo ""

echo "### Other"
git log "$LAST_TAG"..HEAD --pretty="- %s (%h)" --grep="^chore" --grep="^refactor" --grep="^docs" --grep="^ci" || echo "- None"
