#!/usr/bin/env bash
# Finds tRPC routes defined in server but never called from frontend.
# Usage: ./scripts/scan-orphan-routes.sh [src_dir]
set -euo pipefail

SRC="${1:-src}"
SERVER_DIR="$SRC/server/routers"
CLIENT_DIRS="$SRC/features $SRC/app"

if [ ! -d "$SERVER_DIR" ]; then
  echo "No server router directory found at $SERVER_DIR" >&2
  exit 0
fi

echo "## Orphan Route Scan"
echo ""

# Extract procedure names from routers
for router_file in "$SERVER_DIR"/*.ts; do
  [ -f "$router_file" ] || continue
  router_name=$(basename "$router_file" .ts)

  # Find procedure definitions
  grep -oP '(?<=\.)(query|mutation|subscription)\(' "$router_file" 2>/dev/null | while read -r _proc; do
    # Check if router is called from client
    if ! grep -rq "trpc\.$router_name\." $CLIENT_DIRS 2>/dev/null; then
      echo "ORPHAN: $router_name ($router_file) — no client calls found"
    fi
  done
done

echo ""
echo "Done. Review orphans above — some may be internal or webhook-only."
