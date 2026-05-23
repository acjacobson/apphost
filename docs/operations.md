# Operations

## Start shared proxy

```bash
cd /opt/apps/caddy
docker compose up -d
```

## Reload Caddy config

```bash
cd /opt/apps/caddy
docker compose exec caddy caddy reload --config /etc/caddy/Caddyfile
```

## Deploy an app manually

```bash
cd /opt/apps/lab/repo
git fetch origin
git checkout main
git pull origin main
cd /opt/apps/lab
docker compose up -d --build
curl -fsS https://lab.example.com/healthz
```

## Inspect logs

```bash
docker logs --tail=100 apphost-caddy
docker logs --tail=100 lab
```

## Rollback pattern

Use the application repository's git history or pinned image tags. For git-based deployments:

```bash
cd /opt/apps/lab/repo
git checkout <previous-commit>
cd /opt/apps/lab
docker compose up -d --build
```
