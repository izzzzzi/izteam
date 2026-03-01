#!/usr/bin/env bash
# Finds exported symbols that are never imported elsewhere.
# Usage: ./scripts/find-dead-exports.sh [src_dir]
set -euo pipefail

SRC="${1:-src}"

echo "## Dead Export Scan"
echo ""

# Find all export statements
grep -rn "^export " "$SRC" --include="*.ts" --include="*.tsx" 2>/dev/null | while IFS=: read -r file line content; do
  # Extract export names (simplified — catches named exports)
  for name in $(echo "$content" | grep -oP '(?<=export (const|function|class|type|interface|enum) )\w+'); do
    # Count imports of this name excluding the file itself
    import_count=$(grep -rl "\b$name\b" "$SRC" --include="*.ts" --include="*.tsx" 2>/dev/null | grep -v "$file" | wc -l | tr -d ' ')

    if [ "$import_count" -eq 0 ]; then
      echo "DEAD: $name ($file:$line) — 0 external imports"
    fi
  done
done 2>/dev/null

echo ""
echo "Done. Note: some exports may be used dynamically or in tests."
