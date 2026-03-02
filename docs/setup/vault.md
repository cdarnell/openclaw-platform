# Vault Bootstrap Guide

Vault provides PKI issuance, secret storage, and AppRole authentication for OpenClaw services and n8n. This guide walks through initializing and configuring the Dockerized instance shipped in the platform compose stack.

## Prerequisites
- Docker Compose stack running (`platform/scripts/deploy.sh` starts Vault + dependencies).
- gentoofoo root and issuing CA files generated under `pkis/`.
- Root user with access to the OCI host.

## Initialize Vault
1. Ensure the container is up:
   ```bash
   cd /opt/openclaw-platform/platform
   docker compose up -d vault
   ```

2. Initialize Vault (single-node, Shamir 1-of-1 for simplicity – adjust for production):
   ```bash
   ./scripts/vault-init.sh
   ```
   This script runs `vault operator init -key-shares=1 -key-threshold=1`, saves the unseal key/root token to `~/.vault-init/openclaw.txt` (adjust as needed), and unseals the node.

3. Login:
   ```bash
   export VAULT_ADDR=https://127.0.0.1:8200
   export VAULT_CACERT=/opt/openclaw-platform/pkis/ca-chain.pem
   vault login <root-token>
   ```

## Enable Engines
1. **PKI Root + Intermediate**
   ```bash
   vault secrets enable -path=gentoofoo-root pki
   vault secrets tune -max-lease-ttl=87600h gentoofoo-root
   vault write gentoofoo-root/root/generate/internal common_name="gentoofoo Root CA" ttl=87600h

   vault secrets enable -path=gentoofoo-int pki
   vault secrets tune -max-lease-ttl=43800h gentoofoo-int
   vault write gentoofoo-root/root/sign-intermediate csr=@pkis/issuing-ca/intermediate.csr format=pem_bundle ttl=43800h > pkis/issuing-ca/intermediate.pem
   vault write gentoofoo-int/intermediate/set-signed certificate=@pkis/issuing-ca/intermediate.pem
   ```

2. **PKI Roles** (examples)
   ```bash
   vault write gentoofoo-int/roles/openclaw-server allow_any_name=true max_ttl="720h" client_flag=false server_flag=true
   vault write gentoofoo-int/roles/openclaw-client allow_any_name=true max_ttl="720h" client_flag=true server_flag=false
   ```

3. **AppRole Auth**
   ```bash
   vault auth enable approle
   vault policy write openclaw platform/configs/vault/policies/openclaw.hcl
   vault policy write n8n platform/configs/vault/policies/n8n.hcl
   vault write auth/approle/role/openclaw policies="openclaw"
   vault write auth/approle/role/n8n policies="n8n"
   ```

4. **KV Secrets (optional)**
   ```bash
   vault secrets enable -path=secret kv-v2
   vault kv put secret/n8n gmail_client_id=... gmail_client_secret=...
   ```

## Distribute Credentials
- Record each AppRole’s `role_id` and `secret_id` (generated via `vault write -f auth/approle/role/<name>/secret-id`).
- Store these securely (not in the repo). Update `.env` files or Docker secrets to point services to Vault.

## Ongoing Operations
- Rotate intermediate certs using `docs/operations/cert-rotation.md`.
- Back up Vault data regularly (`vault operator raft snapshot save`).
- Monitor Vault health endpoint (`/v1/sys/health`) using the provided health check script and Prometheus target.

For production, expand to multi-node HA, add auto-unseal (OCI KMS), and enforce stricter policies.
