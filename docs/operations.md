# Operations

## Verify the host

```bash
cd /opt/apphost
APP_ROOT=/opt/apps REQUIRE_PROXY=1 ./scripts/verify.sh
```

## Restart the shared proxy

```bash
cd /opt/apps
docker compose up -d traefik
```

## View proxy logs

```bash
docker logs --tail=100 apphost-traefik
```

## List app containers

```bash
docker ps
```

## Backups

Back up host-level proxy data:

```text
/opt/apps/.env
/opt/apps/traefik/letsencrypt/acme.json
```

Application data, app `.env` files, and app volumes are owned by each application and should be covered by that application's operations docs.
