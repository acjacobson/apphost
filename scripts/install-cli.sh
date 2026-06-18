#!/usr/bin/env bash
set -euo pipefail

PREFIX="${PREFIX:-/usr/local}"
APPHOST_DIR="${APPHOST_DIR:-/opt/apphost}"
REGISTRY="${APPHOST_REGISTRY:-$APPHOST_DIR/apps.yml}"

install -d -m 0755 "$PREFIX/bin"
install -m 0755 "$APPHOST_DIR/scripts/apphost" "$PREFIX/bin/apphost"

if [ ! -f "$REGISTRY" ]; then
  install -m 0644 "$APPHOST_DIR/apps.example.yml" "$REGISTRY"
  echo "Created $REGISTRY from apps.example.yml. Edit it for real apps."
else
  echo "Registry already exists: $REGISTRY"
fi

echo "Installed apphost CLI to $PREFIX/bin/apphost"
echo "Try: apphost list"
