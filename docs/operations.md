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

## Container log rotation

Bootstrap adds Docker `json-file` logging defaults of `max-size: 10m` and `max-file: 3` to `/etc/docker/daemon.json`. It preserves unrelated daemon settings and explicit retention settings. If another logging driver is already configured, it leaves that driver untouched; check its retention separately. App-specific Compose logging settings override daemon defaults.

To configure an existing host without rerunning bootstrap:

```bash
sudo python3 /opt/apphost/scripts/configure-docker-logging.py
sudo dockerd --validate --config-file=/etc/docker/daemon.json
```

The helper does not restart Docker. During a maintenance window, restart it with `sudo systemctl restart docker`, then recreate the proxy and each app's containers from their respective Compose directories with `docker compose up -d --force-recreate`. Do not remove data volumes. This can briefly interrupt apps. Docker installation may already have started the daemon on a fresh host, so apply the same restart before deploying your first containers.

Verify a recreated container's effective settings:

```bash
docker inspect --format '{{json .HostConfig.LogConfig}}' apphost-traefik
```

## Backups

Back up host-level proxy data:

```text
/opt/apps/.env
/opt/apps/traefik/letsencrypt/acme.json
```

Application data, app `.env` files, and app volumes are owned by each application and should be covered by that application's operations docs.
