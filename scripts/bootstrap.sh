#!/usr/bin/env bash
set -euo pipefail

if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  echo "Run as root or with sudo."
  exit 1
fi

APP_USER="${APP_USER:-deploy}"
APP_ROOT="${APP_ROOT:-/opt/apps}"
CONFIGURE_UFW="${CONFIGURE_UFW:-0}"

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y \
  ca-certificates \
  curl \
  git \
  gnupg \
  ufw \
  unattended-upgrades

apt-get install -y docker.io

if ! docker compose version >/dev/null 2>&1; then
  if apt-cache show docker-compose-plugin >/dev/null 2>&1; then
    apt-get install -y docker-compose-plugin
  elif apt-cache show docker-compose-v2 >/dev/null 2>&1; then
    apt-get install -y docker-compose-v2
  elif apt-cache show docker-compose >/dev/null 2>&1; then
    apt-get install -y docker-compose
  else
    echo "Could not find a Docker Compose package. Install Docker Compose manually, then re-run bootstrap."
    exit 1
  fi
fi

systemctl enable --now docker

if ! id "$APP_USER" >/dev/null 2>&1; then
  useradd -m -s /bin/bash "$APP_USER"
fi

usermod -aG docker "$APP_USER"
usermod -aG sudo "$APP_USER"

mkdir -p "$APP_ROOT"
chown -R "$APP_USER:$APP_USER" "$APP_ROOT"
chmod 755 "$APP_ROOT"

if ! docker network inspect web >/dev/null 2>&1; then
  docker network create web
fi

if [ "$CONFIGURE_UFW" = "1" ]; then
  ufw allow OpenSSH
  ufw allow 80/tcp
  ufw allow 443/tcp
  ufw --force enable
fi

echo "Bootstrap complete."
echo "App user: $APP_USER"
echo "App root: $APP_ROOT"
echo "Shared Docker network: web"
echo "If $APP_USER was newly added to the docker group, log out and back in before using docker as that user."
