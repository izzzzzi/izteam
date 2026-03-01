#!/usr/bin/env bash
# Safely removes a feature with git backup.
# Usage: ./scripts/safe-cleanup.sh <feature_name> [src_dir]
set -euo pipefail

FEATURE="${1:?Usage: safe-cleanup.sh <feature_name> [src_dir]}"
SRC="${2:-src}"
BRANCH="cleanup/$FEATURE-$(date +%Y%m%d)"

echo "## Safe Cleanup: $FEATURE"
echo ""

# Step 1: Create backup branch
echo "Creating backup branch: $BRANCH"
git checkout -b "$BRANCH"
git add -A && git commit -m "chore: backup before removing $FEATURE" --allow-empty

# Step 2: Find references
echo ""
echo "### References found:"
grep -rn "from.*@/features/$FEATURE" "$SRC" --include="*.ts" --include="*.tsx" 2>/dev/null || echo "No import references found"
echo ""

# Step 3: Remove feature directory
FEATURE_DIR="$SRC/features/$FEATURE"
if [ -d "$FEATURE_DIR" ]; then
  echo "Removing: $FEATURE_DIR"
  rm -rf "$FEATURE_DIR"
else
  echo "Warning: $FEATURE_DIR does not exist" >&2
fi

# Step 4: Remove router if exists
ROUTER_FILE="$SRC/server/routers/$FEATURE.ts"
if [ -f "$ROUTER_FILE" ]; then
  echo "Removing: $ROUTER_FILE"
  rm -f "$ROUTER_FILE"
fi

# Step 5: Verify
echo ""
echo "### Verification:"
if command -v npx &>/dev/null && [ -f "tsconfig.json" ]; then
  if npx tsc --noEmit 2>/dev/null; then
    echo "TypeScript: OK"
  else
    echo "TypeScript: ERRORS — review and fix remaining references" >&2
  fi
fi

remaining=$(grep -rn "$FEATURE" "$SRC" --include="*.ts" --include="*.tsx" 2>/dev/null | wc -l | tr -d ' ')
echo "Remaining references: $remaining"

echo ""
echo "### Rollback command:"
echo "  git checkout main && git branch -D $BRANCH"
