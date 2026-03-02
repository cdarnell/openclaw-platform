#!/usr/bin/env bash
set -euo pipefail
CONF_SOURCE="${1:-/opt/openclaw-platform/platform/configs/wireguard/server.conf}"
CONF_TARGET="/etc/wireguard/wg0.conf"

if [[ $EUID -ne 0 ]]; then
  echo "Run as root" >&2
  exit 1
fi

if [[ ! -f "$CONF_SOURCE" ]]; then
  echo "WireGuard config not found at $CONF_SOURCE" >&2
  exit 1
fi

install -Dm600 "$CONF_SOURCE" "$CONF_TARGET"
systemctl enable wg-quick@wg0
systemctl restart wg-quick@wg0

wg show
