#!/usr/bin/env bash
set -euo pipefail

if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  echo "Run as root or with sudo."
  exit 1
fi

APP_USER="${APP_USER:-deploy}"
APP_ROOT="${APP_ROOT:-/opt/apps}"

apt-get update
apt-get install -y ca-certificates curl gnupg docker.io docker-compose-plugin ufw

if ! id "$APP_USER" >/dev/null 2>&1; then
  useradd -m -s /bin/bash "$APP_USER"
fi
usermod -aG docker "$APP_USER"

mkdir -p "$APP_ROOT"
chown -R "$APP_USER:$APP_USER" "$APP_ROOT"

if ! docker network inspect web >/dev/null 2>&1; then
  docker network create web
fi

echo "Bootstrap complete. Log out and back in if docker group membership was just added."
