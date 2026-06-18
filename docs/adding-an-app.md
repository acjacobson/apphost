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

## App repo deployment contract

The preferred model is still app-owned deployment:

```text
app repo CI passes
→ app repo uploads or checks out source under /opt/apps/<app>/repo
→ app repo copies its production Compose file to /opt/apps/<app>/docker-compose.yml
→ app repo preserves /opt/apps/<app>/.env
→ app repo runs docker compose up -d --build
→ app repo runs migrations, if any
→ app repo smoke-tests its healthcheck
```

For private repositories, do not assume the VM can clone from GitHub. Prefer uploading the GitHub Actions checkout over SSH so GitHub auth stays in Actions.

## One-time host-side app directory

Create the app runtime directory and server-local files on the host:

```bash
APP=example
sudo install -d -o deploy -g deploy -m 0755 "/opt/apps/$APP"
sudo install -d -o deploy -g deploy -m 0755 "/opt/apps/$APP/repo"
sudo install -d -o deploy -g deploy -m 0755 "/opt/apps/$APP/data"
sudo touch "/opt/apps/$APP/.env"
sudo chown deploy:deploy "/opt/apps/$APP/.env"
sudo chmod 600 "/opt/apps/$APP/.env"
```

Put app secrets and hostname values in `/opt/apps/<app>/.env`. Do not commit secrets to Apphost or the app repo.

## Required production Compose shape

The app repo should provide a production Compose file, commonly `deploy/docker-compose.prod.yml`, that is copied to `/opt/apps/<app>/docker-compose.yml` during deploy.

Minimum Traefik shape:

```yaml
services:
  web:
    build:
      context: ./repo
      dockerfile: Dockerfile
    restart: unless-stopped
    env_file:
      - .env
    expose:
      - "3000"
    networks:
      - web
    labels:
      - traefik.enable=true
      - traefik.docker.network=web
      - traefik.http.routers.example.rule=Host(`${EXAMPLE_HOSTNAME}`)
      - traefik.http.routers.example.entrypoints=websecure
      - traefik.http.routers.example.tls=true
      - traefik.http.routers.example.tls.certresolver=letsencrypt
      - traefik.http.services.example.loadbalancer.server.port=3000
      - traefik.http.routers.example-http.rule=Host(`${EXAMPLE_HOSTNAME}`)
      - traefik.http.routers.example-http.entrypoints=web
      - traefik.http.routers.example-http.middlewares=example-https-redirect
      - traefik.http.middlewares.example-https-redirect.redirectscheme.scheme=https

networks:
  web:
    external: true
```

## Typical GitHub Actions deploy step

This pattern uploads the checked-out source from Actions, preserving the Apphost boundary and avoiding VM-side GitHub credentials:

```bash
APP=example
APP_DIR=/opt/apps/example

tar -czf - --exclude='./.git' . | ssh deploy@example-host '
  set -euo pipefail
  APP_DIR=/opt/apps/example
  rm -rf "$APP_DIR/repo"
  mkdir -p "$APP_DIR/repo"
  tar -xzf - -C "$APP_DIR/repo"
  cp "$APP_DIR/repo/deploy/docker-compose.prod.yml" "$APP_DIR/docker-compose.yml"
  cd "$APP_DIR"
  test -f .env
  docker compose up -d --build
'
```

Add migrations before the final smoke test if the app needs them. For one-shot migration commands inside an SSH heredoc, use `docker compose run --rm -T ... < /dev/null` so the command does not consume the rest of stdin.

## Smoke test

Each app repo should verify its public healthcheck after deploy:

```bash
curl -fsS "https://example.com/healthz"
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
