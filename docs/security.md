# Security

## Secrets

Do not commit real secrets. Keep runtime secrets in server-local `.env` files or a secrets manager.

## Access

Use SSH key authentication. Avoid password SSH login on public servers.

## Firewall

Expose only required public ports. A typical web host allows:

- 22/tcp for SSH, restricted when possible
- 80/tcp for HTTP
- 443/tcp for HTTPS

## Review before running scripts

Bootstrap scripts are intentionally small and readable. Review them before executing on a server.
