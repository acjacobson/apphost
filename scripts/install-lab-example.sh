#!/usr/bin/env bash
set -euo pipefail

if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  echo "Run as root or with sudo."
  exit 1
fi

APP_USER="${APP_USER:-deploy}"
APP_ROOT="${APP_ROOT:-/opt/apps}"
LAB_REPO="${LAB_REPO:-https://github.com/acjacobson/lab.git}"
LAB_DIR="$APP_ROOT/lab"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if ! id "$APP_USER" >/dev/null 2>&1; then
  echo "User $APP_USER does not exist. Run scripts/bootstrap.sh first."
  exit 1
fi

mkdir -p "$LAB_DIR"
install -m 0644 "$REPO_ROOT/apps/lab.compose.example.yml" "$LAB_DIR/docker-compose.yml"
chown -R "$APP_USER:$APP_USER" "$LAB_DIR"

if [ ! -d "$LAB_DIR/repo/.git" ]; then
  sudo -u "$APP_USER" git clone "$LAB_REPO" "$LAB_DIR/repo"
else
  sudo -u "$APP_USER" git -C "$LAB_DIR/repo" fetch origin
  sudo -u "$APP_USER" git -C "$LAB_DIR/repo" checkout main
  sudo -u "$APP_USER" git -C "$LAB_DIR/repo" pull --ff-only origin main
fi

cd "$LAB_DIR"
docker compose config >/tmp/apphost-lab-config.yml
docker compose up -d --build

echo "Lab example installed and started."
echo "Directory: $LAB_DIR"
