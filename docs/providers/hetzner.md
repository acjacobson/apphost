# Hetzner notes

Apphost is provider-neutral. These notes cover using the pattern on a Hetzner Cloud VM.

## Recommended VM baseline

- Ubuntu LTS
- Public IPv4 address
- SSH key authentication
- Firewall allowing SSH, HTTP, and HTTPS

## DNS

Create an A record pointing the app hostname to the VM public IP, for example:

```text
lab.example.com -> 203.0.113.10
```

## Provider-specific work not included

This repository does not currently manage Hetzner Cloud resources through Terraform or the Hetzner API. If provider-managed firewalls, volumes, snapshots, or floating IPs become important, add them under a provider-specific directory and keep the generic host pattern separate.
