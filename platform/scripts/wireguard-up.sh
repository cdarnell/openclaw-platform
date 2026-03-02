#!/usr/bin/env bash
set -euo pipefail
CONF_PATH="${1:-/etc/wireguard/wg0.conf}"

if [[ ! -f "$CONF_PATH" ]]; then
  echo "WireGuard config not found at $CONF_PATH" >&2
  exit 1
fi

sudo systemctl enable wg-quick@wg0
sudo systemctl restart wg-quick@wg0
sudo wg show
