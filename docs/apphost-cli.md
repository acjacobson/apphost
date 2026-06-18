# Apphost CLI

Apphost includes a small dependency-free operational CLI. It keeps the runtime model unchanged: apps still deploy themselves with their own Docker Compose files and GitHub Actions workflows.

The CLI adds a central inventory and status surface.

## Registry

The default registry path is:

```text
/opt/apphost/apps.yml
```

Create it from the repo template:

```bash
cp /opt/apphost/apps.example.yml /opt/apphost/apps.yml
```

Example:

```yaml
apps:
  - name: proxima
    repo: acjacobson/proxima
    branch: main
    host: proxima.straylantern.com
    path: /opt/apps/proxima
    compose: /opt/apps/proxima/docker-compose.yml
    healthcheck: https://proxima.straylantern.com/healthz
    env_file: /opt/apps/proxima/.env
    data:
      - /opt/apps/proxima/data/postgres
```

## Install from the Apphost repo

On the server, install from the cloned Apphost repo:

```bash
cd /opt/apphost
git pull --ff-only
sudo APPHOST_DIR=/opt/apphost ./scripts/install-cli.sh
```

This installs:

```text
/usr/local/bin/apphost
```

and creates `/opt/apphost/apps.yml` if missing.

## Commands

```bash
apphost list
apphost status
apphost status proxima
apphost doctor
apphost doctor proxima
apphost logs proxima
apphost logs proxima web --tail 100
```

Use a different registry for testing:

```bash
APPHOST_REGISTRY=./apps.example.yml ./scripts/apphost list
```

## What it checks

`apphost status` checks each registered app:

- app path exists
- compose file exists
- env file exists
- data paths exist, if configured
- containers are listed/running through Docker Compose
- healthcheck returns HTTP 2xx/3xx, if configured

`apphost doctor` checks the host plus apps:

- Docker binary and daemon
- Docker Compose
- external `web` network
- `apphost-traefik` container
- ports 80 and 443 on localhost
- disk free percentage
- app status summary

## Current limitations

This is intentionally not a deploy orchestrator yet.

- It does not mutate app deployments.
- It does not manage DNS.
- It does not manage secrets.
- It does not generate app Compose files.
- It does not replace app-owned GitHub Actions workflows.

That keeps Apphost as the host substrate while making operations less manual.
