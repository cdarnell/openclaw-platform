#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ ! -f .env ]]; then
  echo "[!] Missing .env. Copy from .env.example and update values." >&2
  exit 1
fi

docker compose pull
docker compose up -d

docker compose ps
