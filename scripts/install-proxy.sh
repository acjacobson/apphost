#!/usr/bin/env bash
set -euo pipefail

if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  echo "Run as root or with sudo."
  exit 1
fi

APP_USER="${APP_USER:-deploy}"
APP_ROOT="${APP_ROOT:-/opt/apps}"
TRAEFIK_ACME_EMAIL="${TRAEFIK_ACME_EMAIL:-admin@example.com}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if ! id "$APP_USER" >/dev/null 2>&1; then
  echo "User $APP_USER does not exist. Run scripts/bootstrap.sh first."
  exit 1
fi

if ! docker network inspect web >/dev/null 2>&1; then
  docker network create web
fi

mkdir -p "$APP_ROOT/traefik/letsencrypt"
install -m 0644 "$REPO_ROOT/proxy/compose.yml" "$APP_ROOT/docker-compose.yml"

if [ ! -f "$APP_ROOT/.env" ]; then
  printf 'TRAEFIK_ACME_EMAIL=%s\n' "$TRAEFIK_ACME_EMAIL" > "$APP_ROOT/.env"
else
  if grep -q '^TRAEFIK_ACME_EMAIL=' "$APP_ROOT/.env"; then
    sed -i "s/^TRAEFIK_ACME_EMAIL=.*/TRAEFIK_ACME_EMAIL=$TRAEFIK_ACME_EMAIL/" "$APP_ROOT/.env"
  else
    printf 'TRAEFIK_ACME_EMAIL=%s\n' "$TRAEFIK_ACME_EMAIL" >> "$APP_ROOT/.env"
  fi
fi

touch "$APP_ROOT/traefik/letsencrypt/acme.json"
chmod 600 "$APP_ROOT/traefik/letsencrypt/acme.json"
chown -R "$APP_USER:$APP_USER" "$APP_ROOT"

cd "$APP_ROOT"
docker compose config >/tmp/apphost-proxy-config.yml
docker compose up -d traefik

echo "Traefik installed and started."
echo "Host compose: $APP_ROOT/docker-compose.yml"
echo "Apps can deploy themselves under $APP_ROOT/<app-name> and join the external web network."
