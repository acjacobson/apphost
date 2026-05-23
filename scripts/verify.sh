#!/usr/bin/env bash
set -euo pipefail

APP_ROOT="${APP_ROOT:-/opt/apps}"
REQUIRE_PROXY="${REQUIRE_PROXY:-0}"

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

if [ -f "$APP_ROOT/docker-compose.yml" ]; then
  echo "== Host compose config =="
  (cd "$APP_ROOT" && docker compose config >/tmp/apphost-proxy-config.yml)
fi

if [ "$REQUIRE_PROXY" = "1" ]; then
  echo "== Traefik container =="
  docker inspect apphost-traefik >/dev/null
  docker ps --filter name=apphost-traefik --filter status=running --format '{{.Names}} {{.Status}}'
fi

echo "Apphost verification passed."
