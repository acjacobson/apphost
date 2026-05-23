# Architecture

Apphost is a generic host pattern for running multiple web apps on one Linux server.

## Core components

- Docker runs each app in an isolated container or compose project.
- A shared Docker network named `web` lets the reverse proxy reach app containers by service name.
- Caddy terminates HTTP/HTTPS traffic and routes hostnames to apps.
- Each app keeps its own source code, runtime config, and deploy process.

## Directory model

A typical server layout is:

```text
/opt/apps/
  caddy/
    docker-compose.yml
    Caddyfile
  lab/
    docker-compose.yml
    .env
    repo/
  another-app/
    docker-compose.yml
    .env
    repo/
```

This repository provides examples and bootstrap helpers for that pattern. Exact server files should be reviewed before applying them in production.
