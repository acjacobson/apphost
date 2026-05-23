# First server setup

This guide bootstraps a fresh Linux server into an Apphost machine that can run multiple Docker Compose applications behind Caddy.

The commands assume a fresh Ubuntu server and a root shell from SSH or the provider console.

## 1. Install git and clone Apphost

```bash
apt-get update
apt-get install -y git
mkdir -p /opt
if [ ! -d /opt/apphost ]; then
  git clone https://github.com/acjacobson/apphost.git /opt/apphost
else
  git -C /opt/apphost pull --ff-only
fi
cd /opt/apphost
```

## 2. Bootstrap the host

This installs Docker, Docker Compose, UFW, unattended upgrades, creates the deploy user, creates `/opt/apps`, and creates the shared `web` Docker network.

Ubuntu package names for Docker Compose vary by release. The bootstrap script tries `docker-compose-plugin`, `docker-compose-v2`, and `docker-compose` as fallbacks after installing `docker.io`.

```bash
APP_USER=deploy APP_ROOT=/opt/apps ./scripts/bootstrap.sh
```

Optional: enable a basic firewall during bootstrap:

```bash
CONFIGURE_UFW=1 APP_USER=deploy APP_ROOT=/opt/apps ./scripts/bootstrap.sh
```

The firewall allows SSH, HTTP, and HTTPS.

## 3. Add your SSH key for the deploy user

From your workstation, copy your public key. It usually lives at `~/.ssh/id_ed25519.pub`.

On the server:

```bash
install -d -m 700 -o deploy -g deploy /home/deploy/.ssh
cat >> /home/deploy/.ssh/authorized_keys <<'EOF'
PASTE_PUBLIC_KEY_HERE
EOF
chown deploy:deploy /home/deploy/.ssh/authorized_keys
chmod 600 /home/deploy/.ssh/authorized_keys
```

Open a second terminal and verify key-based login before changing SSH security settings:

```bash
ssh deploy@SERVER_IP 'whoami && hostname'
```

## 4. Optional SSH hardening

Only run this after key-based login works for `deploy`.

```bash
CONFIRM_SSH_HARDEN=1 APP_USER=deploy ./scripts/harden-ssh.sh
```

This disables password SSH login and restricts root to key-based login. Keep the current server session open while testing a new SSH session.

## 5. Install shared Caddy proxy

Use a real email address and the hostname that should route to the Lab app.

```bash
CADDY_EMAIL=admin@example.com LAB_HOSTNAME=lab.example.com ./scripts/install-caddy.sh
```

Caddy runs with Docker restart policy `unless-stopped`, so it starts again after container failure or server reboot.

## 6. Verify the host

```bash
REQUIRE_CADDY=1 ./scripts/verify.sh
```

## 7. Configure GitHub Actions deployment

The `Deploy Lab` workflow in this repository deploys the Lab app to the host over SSH. It is manually triggered with `workflow_dispatch` so infrastructure changes do not deploy automatically.

Add these repository secrets to the Apphost GitHub repository:

```text
APPHOST_HOST=SERVER_IP_OR_HOSTNAME
APPHOST_USER=deploy
APPHOST_SSH_KEY=CONTENTS_OF_PRIVATE_DEPLOY_KEY
APPHOST_APP_DIR=/opt/apps/lab
```

Optional, after DNS and Caddy are ready:

```text
APPHOST_DEPLOY_URL=https://lab.example.com
```

The deploy workflow uploads the Lab compose file from this repository, clones or updates `https://github.com/acjacobson/lab.git` on the server, runs `docker compose up -d --build`, and performs an internal health check.

## 8. Later: install the Lab example app manually

If you want to deploy Lab manually instead of using GitHub Actions:

```bash
./scripts/install-lab-example.sh
```

Then verify internally:

```bash
docker exec lab python -c "import urllib.request; print(urllib.request.urlopen('http://127.0.0.1:8080/healthz', timeout=10).read().decode())"
```

After DNS and Caddy are configured, verify externally:

```bash
curl -fsS https://lab.example.com/healthz
```
