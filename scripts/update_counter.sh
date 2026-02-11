#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COUNTER_FILE="$REPO_DIR/.counter"
README_FILE="$REPO_DIR/README.md"

cd "$REPO_DIR"

# Ensure we are up to date before making changes
git pull --rebase origin main >/dev/null 2>&1 || true

if [[ ! -f "$COUNTER_FILE" ]]; then
  echo 0 > "$COUNTER_FILE"
fi

current_value=$(cat "$COUNTER_FILE" 2>/dev/null || echo 0)
if ! [[ "$current_value" =~ ^[0-9]+$ ]]; then
  current_value=0
fi

next_value=$((current_value + 1))
echo "$next_value" > "$COUNTER_FILE"

timestamp=$(date -u +"%Y-%m-%d %H:%M:%S UTC")

cat > "$README_FILE" <<EOF
# OpenClaw Test
Repository for OpenClaw experiments.

## Hourly Counter
Counter: $next_value
Last updated: $timestamp
EOF

if git status --short | grep -qE 'README.md|\.counter'; then
  git add "$README_FILE" "$COUNTER_FILE"
  git commit -m "chore: update counter to $next_value" >/dev/null 2>&1 || true
  git push origin main >/dev/null 2>&1 || true
fi
