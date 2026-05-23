# Apphost

Apphost is a generic multi-application host configuration for a Linux server running Docker Compose and Caddy.

It is intended to host several independently deployed web applications on one server. Each app has its own directory, compose file, environment file, and hostname route.

## What this repo owns

- Docker installation bootstrap helpers
- A shared Caddy reverse proxy
- A shared Docker network for HTTP routing
- Examples for adding apps
- Host-level operations documentation

## What this repo does not own

- Application source code
- Application tests
- Application-specific business configuration
- Secret values
- Provider-specific infrastructure unless documented under `docs/providers/`

## First server setup

Use the provider console or an SSH root session on a fresh server:

```bash
apt-get update
apt-get install -y git
git clone https://github.com/acjacobson/apphost.git /opt/apphost
cd /opt/apphost
APP_USER=deploy APP_ROOT=/opt/apps ./scripts/bootstrap.sh
```

Then follow `docs/first-server-setup.md` to add SSH keys, optionally harden SSH, install Caddy, and verify the host.

## Common commands

```bash
./scripts/bootstrap.sh
./scripts/install-caddy.sh
./scripts/verify.sh
```

Review scripts before running them on a server.
