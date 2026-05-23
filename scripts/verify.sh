#!/usr/bin/env bash
set -euo pipefail

docker --version
docker compose version
docker network inspect web >/dev/null

echo "Docker and shared web network are available."
