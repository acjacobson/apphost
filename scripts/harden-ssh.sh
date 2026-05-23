#!/usr/bin/env bash
set -euo pipefail

if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  echo "Run as root or with sudo."
  exit 1
fi

APP_USER="${APP_USER:-deploy}"
CONFIRM="${CONFIRM_SSH_HARDEN:-0}"
DROPIN_DIR="/etc/ssh/sshd_config.d"
DROPIN_FILE="$DROPIN_DIR/99-apphost-hardening.conf"

if [ "$CONFIRM" != "1" ]; then
  echo "This script disables password SSH login and restricts root to key-based login."
  echo "Before running it, verify that key-based SSH works for $APP_USER."
  echo "Re-run with CONFIRM_SSH_HARDEN=1 when ready."
  exit 1
fi

if ! id "$APP_USER" >/dev/null 2>&1; then
  echo "User $APP_USER does not exist. Run scripts/bootstrap.sh first."
  exit 1
fi

if [ ! -s "/home/$APP_USER/.ssh/authorized_keys" ]; then
  echo "/home/$APP_USER/.ssh/authorized_keys is missing or empty. Refusing to harden SSH."
  exit 1
fi

mkdir -p "$DROPIN_DIR"
cat > "$DROPIN_FILE" <<EOF
PubkeyAuthentication yes
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin prohibit-password
EOF

sshd -t
systemctl reload ssh || systemctl reload sshd

echo "SSH hardening applied: $DROPIN_FILE"
echo "Keep your current session open and test a new SSH login before closing it."
