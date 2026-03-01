#!/usr/bin/env bash
# Analyzes import usage of each feature directory.
# Usage: ./scripts/analyze-feature-usage.sh [src_dir]
set -euo pipefail

SRC="${1:-src}"
FEATURES_DIR="$SRC/features"

if [ ! -d "$FEATURES_DIR" ]; then
  echo "No features directory found at $FEATURES_DIR" >&2
  exit 0
fi

echo "## Feature Usage Analysis"
echo ""
echo "| Feature | External Imports | Last Commit | Status |"
echo "|---------|-----------------|-------------|--------|"

for feature_dir in "$FEATURES_DIR"/*/; do
  [ -d "$feature_dir" ] || continue
  feature_name=$(basename "$feature_dir")

  # Count external imports
  external_count=$(grep -rl "from.*@/features/$feature_name" "$SRC" --include="*.ts" --include="*.tsx" 2>/dev/null | grep -v "$FEATURES_DIR/$feature_name" | wc -l | tr -d ' ')

  # Last commit date
  last_commit=$(git log -1 --format="%cr" -- "$feature_dir" 2>/dev/null || echo "unknown")

  # Determine status
  if [ "$external_count" -eq 0 ]; then
    status="UNUSED"
  elif [ "$external_count" -le 2 ]; then
    status="LOW"
  else
    status="ACTIVE"
  fi

  echo "| $feature_name | $external_count | $last_commit | $status |"
done
