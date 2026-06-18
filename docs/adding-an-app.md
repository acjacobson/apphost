# Adding an application

Applications are added by their own repositories. Apphost only provides the shared Docker host and Traefik proxy.

## Requirements for an app repo

An app repo should provide:

- a Dockerfile
- a production Docker Compose file
- a GitHub Actions deployment workflow or equivalent deploy script
- Traefik labels for the app hostname
- a smoke test

## Host contract

The host provides:

- SSH access as `deploy`
- app root at `/opt/apps`
- external Docker network `web`
- Traefik listening on 80 and 443
- optional operational registry entry in `/opt/apphost/apps.yml`

## Typical deploy flow from an app repo

```bash
ssh deploy@example-host '
  set -e
  mkdir -p /opt/apps/example
  cd /opt/apps/example
  git clone https://github.com/example/example.git repo || true
  git -C repo fetch origin
  git -C repo checkout main
  git -C repo pull --ff-only origin main
  cp repo/deploy/docker-compose.prod.yml docker-compose.yml
  docker compose up -d --build
'
```

The exact deploy flow belongs to the app repo, not Apphost.

## Register for operations

After the app deploy path exists, add an inventory entry so the host can report status consistently:

```yaml
apps:
  - name: example
    repo: example/example
    branch: main
    host: example.com
    path: /opt/apps/example
    compose: /opt/apps/example/docker-compose.yml
    healthcheck: https://example.com/healthz
    env_file: /opt/apps/example/.env
    data:
      - /opt/apps/example/data
```

Then verify:

```bash
apphost status example
apphost doctor example
```
