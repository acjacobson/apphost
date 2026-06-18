# Apphost

Apphost is a generic multi-application host setup for a Linux server running Docker Compose and Traefik.

It provisions the server substrate only. Application repositories own their own deployment workflows and deploy themselves onto the host.

## What this repo owns

- Docker installation bootstrap helpers
- A shared Docker network named `web`
- A shared Traefik reverse proxy
- A small `apphost` operations CLI
- A central app registry at `/opt/apphost/apps.yml`
- Host-level firewall and SSH hardening helpers
- Host-level operations documentation

## What this repo does not own

- Application source code
- Application deployment workflows
- Application-specific compose files
- Application `.env` files
- Application domains or service labels
- Secret values

## First server setup

Use the provider console or an SSH root session on a fresh server:

```bash
apt-get update
apt-get install -y git
git clone https://github.com/acjacobson/apphost.git /opt/apphost
cd /opt/apphost
APP_USER=deploy APP_ROOT=/opt/apps ./scripts/bootstrap.sh
TRAEFIK_ACME_EMAIL=admin@example.com APP_ROOT=/opt/apps ./scripts/install-proxy.sh
APPHOST_DIR=/opt/apphost ./scripts/install-cli.sh
APP_ROOT=/opt/apps REQUIRE_PROXY=1 ./scripts/verify.sh
```

## Operations CLI

After setup, use the app registry and CLI for inventory and basic diagnostics:

```bash
sudo nano /opt/apphost/apps.yml
apphost list
apphost status
apphost doctor
apphost logs <app>
```

See `docs/apphost-cli.md`.
