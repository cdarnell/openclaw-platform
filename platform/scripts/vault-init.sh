#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if ! docker ps --filter "name=openclaw-vault" --filter "status=running" --format '{{.ID}}' | grep -q .; then
  echo "[!] Vault container is not running." >&2
  exit 1
fi

VAULT_EXEC="docker exec openclaw-vault env VAULT_ADDR=https://127.0.0.1:8200 VAULT_CACERT=/certs/gentoofoo-chain.pem"

INIT_DIR=${HOME}/.vault-init
mkdir -p "$INIT_DIR"
OUT_FILE="$INIT_DIR/openclaw-$(date +%Y%m%d-%H%M%S).txt"

echo "[*] Initializing Vault"
INIT_JSON=$($VAULT_EXEC vault operator init -format=json -key-shares=1 -key-threshold=1)
UNSEAL_KEY=$(echo "$INIT_JSON" | jq -r '.unseal_keys_b64[0]')
ROOT_TOKEN=$(echo "$INIT_JSON" | jq -r '.root_token')

echo "Unseal Key: $UNSEAL_KEY" > "$OUT_FILE"
echo "Root Token: $ROOT_TOKEN" >> "$OUT_FILE"
chmod 600 "$OUT_FILE"

echo "[*] Unsealing"
$VAULT_EXEC vault operator unseal "$UNSEAL_KEY"

echo "[+] Vault initialized. Credentials stored in $OUT_FILE"
