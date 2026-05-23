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

## Quick start

Review scripts before running them on a server.

```bash
./scripts/bootstrap.sh
./scripts/verify.sh
```

Copy examples into place and customize hostnames, app names, and paths for the target environment.
