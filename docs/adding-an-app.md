# Adding an app

This guide describes the generic process for adding an application to an Apphost server.

## 1. Create an app directory

```bash
sudo mkdir -p /opt/apps/my-app
sudo chown -R deploy:deploy /opt/apps/my-app
```

## 2. Add app source or image configuration

For a git-based deployment:

```bash
cd /opt/apps/my-app
git clone https://github.com/example/my-app.git repo
```

## 3. Add a compose file

The app compose file should join the external `web` network and expose its internal HTTP port.

```yaml
services:
  my-app:
    build:
      context: ./repo
      dockerfile: deploy/Dockerfile
    restart: unless-stopped
    expose:
      - "8080"
    networks:
      - web

networks:
  web:
    external: true
```

## 4. Add a Caddy route

```caddyfile
my-app.example.com {
    reverse_proxy my-app:8080
}
```

## 5. Start and verify

```bash
cd /opt/apps/my-app
docker compose up -d --build
curl -fsS https://my-app.example.com/healthz
```
