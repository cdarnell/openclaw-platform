# OpenClaw Platform

A hardened, zero-trust OpenClaw + n8n + WireGuard + mTLS + Vault + Observability platform for gentoofoo.com. OpenClaw is a security-first autonomous agent stack designed for isolated environments. The reference deployment targets an Oracle Cloud Infrastructure (OCI) VM and relies on a layered defense strategy:

- **WireGuard tunnel** between OCI and your on-prem network (Ollama, operators).
- **gentoofoo Internal CA** for mutual TLS identity on every service.
- **Vault** for secret storage, PKI issuance, and policy enforcement.
- **OpenClaw core services** (gateway, planner, executor) and **n8n** automation engine.
- **Observability stack** (Prometheus, Loki, Grafana, Vector, node exporter, cAdvisor).
- **Terraform + scripts** for repeatable infrastructure, certificate ops, and health checks.

This repository provides all artifacts needed to bootstrap the platform, including PKI scripts, WireGuard configs, Docker Compose stacks, Vault policies, integration docs, and automated health checks.

## Getting Started

1. **Prepare OCI host**
   - Provision an Ubuntu 22.04/24.04 VM with a static public IP.
   - Open ports: `22/tcp` (SSH), `51820/udp` (WireGuard), and optional observability ingress if you need remote dashboards.
   - Run `infra/scripts/bootstrap-oci.sh` to install Docker, WireGuard, Vault, and supporting packages.

2. **Generate PKI materials**
   - Use the scripts under `pkis/` to create the gentoofoo root CA and issuing CA.
   - Issue server and client certificates for OpenClaw, n8n, Vault, and operators. Keep private keys secure.

3. **Configure WireGuard tunnel**
   - Edit `platform/configs/wireguard/server.conf` with OCI public endpoint info.
   - Generate client configs from `client-template.conf` for your home Ollama host and operator devices.
   - Apply configs using `platform/scripts/wireguard-up.sh` (OCI) and your preferred WireGuard client on other peers.

4. **Bootstrap Vault**
   - Start the platform stack (`platform/scripts/deploy.sh`).
   - Initialize Vault with `platform/scripts/vault-init.sh`, store unseal keys/root token offline.
   - Enable PKI engines and create roles/policies from `platform/configs/vault/`.

5. **Start OpenClaw + n8n**
   - Update `.env` in `platform/` with executable paths, Ollama endpoint (tunneled address), and Vault/AppRole credentials.
   - Launch containers via `docker compose up -d`.
   - Access n8n through the WireGuard tunnel using its gentoofoo-issued certificate.

6. **Deploy observability stack**
   - Populate `observability/prometheus/prometheus.yml` targets with WireGuard IPs.
   - Run `observability/scripts/deploy.sh` to launch Prometheus, Loki, Grafana, Vector, node exporter, and cAdvisor.
   - Import dashboards under `observability/grafana/dashboards/`.

7. **Health checks**
   - Schedule `tests/health-check.sh` via cron (`tests/cron/health-check.cron`) to continuously validate gateway, n8n, Vault, and WireGuard connectivity.

## Repository Map

- `docs/` – architecture overview, setup guides, operations playbooks, API references.
- `pkis/` – root/intermediate CA configs and issuance scripts.
- `infra/` – Terraform for OCI + DNS, bootstrap scripts.
- `platform/` – Docker Compose stack, configs, Vault policies, WireGuard templates, deployment scripts.
- `observability/` – Prometheus/Loki/Grafana/Vector stack with dashboards.
- `tests/` – health check harness and scheduling examples.
- `.github/workflows/` – linting and security automation (placeholder workflows).

## Security Posture

- All traffic flows through WireGuard; no public HTTP endpoints by default.
- Mutual TLS is mandatory for every service and client, anchored to the gentoofoo CA.
- Vault issues short-lived certificates and stores service secrets; raw keys never live in the repo.
- Observability runs on the same host and only listens on WireGuard/localhost addresses.

## Next Steps

- Extend Terraform automation to provision OCI resources end-to-end.
- Add Traefik or another reverse proxy only if a public HTTPS entrypoint is required.
- Integrate additional workflows (Telegram, Gmail, etc.) once n8n is online.

See `docs/overview.md` for a deeper architecture walkthrough and `docs/setup/oci.md` for step-by-step provisioning instructions.
