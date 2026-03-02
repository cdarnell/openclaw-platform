#!/usr/bin/env bash
set -euo pipefail
CONFIG_FILE="${1:-./health-check.conf}"
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Missing config file $CONFIG_FILE" >&2
  exit 1
fi
source "$CONFIG_FILE"

function check() {
  local name=$1
  local cmd=$2
  echo "[+] Checking $name"
  if ! eval "$cmd" >/tmp/openclaw-health.log 2>&1; then
    echo "[!] $name check failed" >&2
    cat /tmp/openclaw-health.log >&2
    return 1
  fi
}

check "wireguard" "sudo wg show | grep -q 'latest handshake'"
check "gateway" "curl -sf --cert $CLIENT_CERT --key $CLIENT_KEY --cacert $CA_CHAIN https://$GATEWAY_HOST/health"
check "n8n" "curl -sf --cert $CLIENT_CERT --key $CLIENT_KEY --cacert $CA_CHAIN https://$N8N_HOST/rest/health"
check "vault" "curl -sf --cert $CLIENT_CERT --key $CLIENT_KEY --cacert $CA_CHAIN https://$VAULT_HOST:8200/v1/sys/health | jq -e '.sealed == false'"

echo "[OK] All checks passed"
