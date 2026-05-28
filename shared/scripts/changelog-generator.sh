#!/bin/bash
set -euo pipefail

# When a previous tag exists, list commits since it; otherwise walk the full
# history (a two-dot "$ROOT..HEAD" range would exclude the root commit, dropping
# the very first commit on a project's initial release).
if LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null); then
  RANGE="${LAST_TAG}..HEAD"
  SINCE="$LAST_TAG"
else
  RANGE="HEAD"
  SINCE="the beginning"
fi

# `git log --grep` exits 0 even with zero matches, so a `|| echo "- None"`
# fallback never fires. Capture the output and substitute "- None" when empty.
print_section() {
  local title="$1"
  shift
  local commits
  commits=$(git log "$RANGE" --pretty="- %s (%h)" "$@")
  echo "### ${title}"
  echo "${commits:-- None}"
  echo ""
}

echo "# Changelog"
echo ""
echo "## Changes since ${SINCE}"
echo ""

print_section "Features" --grep="^feat"
print_section "Bug Fixes" --grep="^fix"
print_section "Other" --grep="^chore" --grep="^refactor" --grep="^docs" --grep="^ci"
