# Security

## Secrets

Do not commit real secrets. Keep runtime secrets in server-local `.env` files, GitHub Actions secrets, or a secrets manager.

## Access

Use SSH key authentication for the deploy user. Avoid password SSH login on public servers.

Recommended sequence:

1. Bootstrap the host.
2. Add a public SSH key to `/home/deploy/.ssh/authorized_keys`.
3. Test a new SSH session as `deploy`.
4. Run `scripts/harden-ssh.sh` with `CONFIRM_SSH_HARDEN=1`.
5. Keep the original session open until the new hardened login has been tested.

## Firewall

Expose only required public ports. A typical web host allows:

- 22/tcp for SSH, restricted when possible
- 80/tcp for HTTP
- 443/tcp for HTTPS

`scripts/bootstrap.sh` can enable a basic UFW firewall if run with `CONFIGURE_UFW=1`.

## Restart behavior

The shared Traefik proxy uses Docker restart policy `unless-stopped`. Application repositories should use an appropriate restart policy for their own services.

## Review before running scripts

Bootstrap scripts are intentionally small and readable. Review them before executing on a server.
