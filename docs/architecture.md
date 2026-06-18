# Architecture

Apphost prepares a generic Docker host for multiple independently deployed applications.

## Responsibilities

Apphost owns:

- the Linux host bootstrap
- the `deploy` user
- the shared app root, default `/opt/apps`
- the external Docker network named `web`
- the shared Traefik reverse proxy
- host-level firewall and SSH hardening helpers

Application repositories own:

- app source code
- app Dockerfile
- app compose file
- app environment variables
- app domain labels
- app deployment workflow
- app smoke tests

Apphost also keeps a host-local app registry at `/opt/apphost/apps.yml`. The registry is an operational inventory, not the app deploy source. It lets `apphost status`, `apphost doctor`, and `apphost logs <app>` find the right paths and healthchecks without moving deployment ownership out of app repositories.

## Runtime layout

```text
/opt/apps/
  docker-compose.yml        # shared Traefik proxy only
  .env                      # proxy-level environment, no app secrets
  traefik/
    letsencrypt/
      acme.json
  <app-name>/
    docker-compose.yml      # app-owned
    .env                    # app-owned
    repo/                   # app-owned checkout, if using git-pull deploys
```

## Routing model

Traefik watches Docker labels. Apps opt in by joining the external `web` network and setting labels on their own container, for example:

```yaml
labels:
  - traefik.enable=true
  - traefik.http.routers.example.rule=Host(`example.com`)
  - traefik.http.routers.example.entrypoints=websecure
  - traefik.http.routers.example.tls.certresolver=letsencrypt
  - traefik.http.services.example.loadbalancer.server.port=8080
```

This lets app repositories deploy themselves without editing Apphost files.
