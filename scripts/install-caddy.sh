#!/usr/bin/env bash
set -euo pipefail

if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  echo "Run as root or with sudo."
  exit 1
fi

APP_USER="${APP_USER:-deploy}"
APP_ROOT="${APP_ROOT:-/opt/apps}"
CADDY_EMAIL="${CADDY_EMAIL:-admin@example.com}"
LAB_HOSTNAME="${LAB_HOSTNAME:-lab.example.com}"
FORCE="${FORCE:-0}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CADDY_DIR="$APP_ROOT/caddy"

if ! id "$APP_USER" >/dev/null 2>&1; then
  echo "User $APP_USER does not exist. Run scripts/bootstrap.sh first."
  exit 1
fi

mkdir -p "$CADDY_DIR"
install -m 0644 "$REPO_ROOT/caddy/compose.yml" "$CADDY_DIR/docker-compose.yml"

if [ -f "$CADDY_DIR/Caddyfile" ] && [ "$FORCE" != "1" ]; then
  echo "$CADDY_DIR/Caddyfile already exists. Set FORCE=1 to replace it."
else
  python3 - "$CADDY_EMAIL" "$LAB_HOSTNAME" "$CADDY_DIR/Caddyfile" <<'PY'
from pathlib import Path
import sys
email, hostname, target = sys.argv[1:4]
Path(target).write_text(f'''{{
    email {email}
}}

{hostname} {{
    reverse_proxy lab:8080
}}

# Add more apps by routing each hostname to the service name and internal port:
#
# app.example.com {{
#     reverse_proxy app:8080
# }}
''')
PY
fi

chown -R "$APP_USER:$APP_USER" "$CADDY_DIR"

if ! docker network inspect web >/dev/null 2>&1; then
  docker network create web
fi

cd "$CADDY_DIR"
docker compose config >/tmp/apphost-caddy-config.yml
docker compose up -d

echo "Caddy installed and started."
echo "Config: $CADDY_DIR/Caddyfile"
echo "Compose: $CADDY_DIR/docker-compose.yml"
