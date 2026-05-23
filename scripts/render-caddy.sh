#!/usr/bin/env bash
set -euo pipefail

SOURCE="${1:-caddy/Caddyfile.example}"
TARGET="${2:-/opt/apps/caddy/Caddyfile}"

if [ ! -f "$SOURCE" ]; then
  echo "Source Caddyfile not found: $SOURCE"
  exit 1
fi

install -D -m 0644 "$SOURCE" "$TARGET"
echo "Installed $TARGET"
