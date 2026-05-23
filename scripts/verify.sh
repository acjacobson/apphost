#!/usr/bin/env bash
set -euo pipefail

APP_ROOT="${APP_ROOT:-/opt/apps}"
REQUIRE_CADDY="${REQUIRE_CADDY:-0}"

echo "== OS =="
if [ -f /etc/os-release ]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  echo "${PRETTY_NAME:-unknown}"
else
  uname -a
fi

echo "== Docker =="
docker --version
docker compose version
docker info >/dev/null

echo "== Shared network =="
docker network inspect web >/dev/null
echo "web network exists"

echo "== App root =="
test -d "$APP_ROOT"
ls -ld "$APP_ROOT"

if [ -d "$APP_ROOT/caddy" ]; then
  echo "== Caddy compose config =="
  (cd "$APP_ROOT/caddy" && docker compose config >/tmp/apphost-caddy-config.yml)
fi

if [ "$REQUIRE_CADDY" = "1" ]; then
  echo "== Caddy container =="
  docker inspect apphost-caddy >/dev/null
  docker ps --filter name=apphost-caddy --filter status=running --format '{{.Names}} {{.Status}}'
fi

echo "Apphost verification passed."
