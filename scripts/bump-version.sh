#!/bin/bash
# Usage: ./scripts/bump-version.sh [major|minor|patch]
# Bumps the unified repo version and all changed plugin versions.
# Example: ./scripts/bump-version.sh patch
#          ./scripts/bump-version.sh minor

set -euo pipefail

BUMP="${1:-patch}"
MARKETPLACE_JSON=".claude-plugin/marketplace.json"

if [ ! -f "$MARKETPLACE_JSON" ]; then
  echo "ERROR: $MARKETPLACE_JSON not found"
  exit 1
fi

# Bump unified version
CURRENT=$(jq -r '.version' "$MARKETPLACE_JSON")
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT"

case "$BUMP" in
  major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
  minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
  patch) PATCH=$((PATCH + 1)) ;;
  *) echo "ERROR: Invalid bump type: $BUMP (use major|minor|patch)"; exit 1 ;;
esac

NEW="${MAJOR}.${MINOR}.${PATCH}"
jq --arg v "$NEW" '.version = $v' "$MARKETPLACE_JSON" > tmp.json && mv tmp.json "$MARKETPLACE_JSON"

echo "Unified version: $CURRENT -> $NEW"
echo ""
echo "Next steps:"
echo "  git add $MARKETPLACE_JSON"
echo "  git commit -m \"release: v$NEW\""
echo "  git tag v$NEW"
echo "  git push origin main --tags"
