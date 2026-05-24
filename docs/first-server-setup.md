# First server setup

This guide bootstraps a fresh Linux server into an Apphost machine that can run multiple Docker Compose applications behind Traefik.

Apphost does not deploy applications. Each application repository deploys itself onto the prepared host.

## 1. Install git and clone Apphost

Run as `root` from SSH or the provider console:

```bash
apt-get update
apt-get install -y git
mkdir -p /opt
if [ ! -d /opt/apphost ]; then
  git clone https://github.com/acjacobson/apphost.git /opt/apphost
else
  git -C /opt/apphost pull --ff-only
fi
cd /opt/apphost
```

## 2. Bootstrap the host

This installs Docker, Docker Compose, UFW, unattended upgrades, creates the deploy user, creates the app root, and creates the shared `web` Docker network.

Ubuntu package names for Docker Compose vary by release. The bootstrap script tries `docker-compose-plugin`, `docker-compose-v2`, and `docker-compose` as fallbacks after installing `docker.io`.

```bash
APP_USER=deploy APP_ROOT=/opt/apps ./scripts/bootstrap.sh
```

Optional: enable a basic firewall during bootstrap:

```bash
CONFIGURE_UFW=1 APP_USER=deploy APP_ROOT=/opt/apps ./scripts/bootstrap.sh
```

The firewall allows SSH, HTTP, and HTTPS.

## 3. Add SSH keys for deployment users

Application repositories deploy over SSH as the `deploy` user. Use a separate deploy key per app repository so access can be rotated or revoked app-by-app. Store the private key as that app repo's `DEPLOY_SSH_KEY` secret and add only the matching public key to the VM.

```bash
install -d -m 700 -o deploy -g deploy /home/deploy/.ssh
cat >> /home/deploy/.ssh/authorized_keys <<'EOF'
PASTE_APP_PUBLIC_DEPLOY_KEY_HERE
EOF
chown deploy:deploy /home/deploy/.ssh/authorized_keys
chmod 600 /home/deploy/.ssh/authorized_keys
```

## 4. Optional SSH hardening

Only run this after key-based login works for `deploy`.

```bash
CONFIRM_SSH_HARDEN=1 APP_USER=deploy ./scripts/harden-ssh.sh
```

This disables password SSH login and restricts root to key-based login. Keep the current server session open while testing a new SSH session.

## 5. Install shared Traefik proxy

Use a real email address for Let's Encrypt notices.

```bash
TRAEFIK_ACME_EMAIL=admin@example.com APP_ROOT=/opt/apps ./scripts/install-proxy.sh
```

Traefik listens on ports 80 and 443, watches Docker labels, and routes applications that opt in with labels. Applications join the external `web` network and define their own host rules.

## 6. Verify the host

```bash
APP_ROOT=/opt/apps REQUIRE_PROXY=1 ./scripts/verify.sh
```

Expected ending:

```text
Apphost verification passed.
```

## Application deployment contract

Each application repository is responsible for:

1. Creating or updating its directory under `/opt/apps/<app-name>`.
2. Providing its own Dockerfile and Docker Compose config.
3. Joining the external `web` Docker network.
4. Adding Traefik labels for its own hostname.
5. Running `docker compose up -d --build` for its own service.
6. Running its own smoke checks.

Apphost should not contain app-specific deployment workflows or app-specific services.
