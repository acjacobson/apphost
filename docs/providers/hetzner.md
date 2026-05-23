# Provider notes: Hetzner

Apphost is provider-neutral. These notes are for using a generic Hetzner Cloud VM as the host.

## Server image

Use an Ubuntu LTS image.

## Firewall

At minimum, allow:

- 22/tcp for SSH
- 80/tcp for HTTP
- 443/tcp for HTTPS

You can use Hetzner Cloud firewall rules, UFW on the server, or both.

## DNS

For each application, create an `A` record pointing the app hostname to the VM IPv4 address. The application repository owns the hostname and Traefik labels for that app.
