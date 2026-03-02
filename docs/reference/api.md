# API Reference Snapshot

This repo does not implement OpenClaw itself, but documents how the platform expects to interact with the agent runtime and n8n.

## OpenClaw Gateway
- **Base URL**: `https://gateway.openclaw.internal` (WireGuard IP).
- **Authentication**: mTLS (client cert signed by gentoofoo CA) plus optional bearer token from Vault.
- **Endpoints**
  - `GET /health` – returns `{ "status": "ok", "version": "<semver>" }`.
  - `POST /agents/<id>/tasks` – dispatch task to planner/executor cluster.
  - `GET /agents/<id>/status` – returns planner/executor heartbeat info.

## n8n
- **Base URL**: `https://n8n.openclaw.internal`.
- **Auth**: mTLS + n8n credentials stored in Vault.
- **Health**: `GET /rest/health`.
- **Webhook Entry**: `POST /webhook/<id>/<token>` (only accessible over WireGuard).

## Vault
- **Base URL**: `https://vault.openclaw.internal:8200`.
- **Auth Methods**: AppRole for services, TLS certificates for operators.
- **Notable Paths**:
  - `gentoofoo-int/issue/openclaw-server`
  - `gentoofoo-int/issue/openclaw-client`
  - `secret/data/n8n`

## Observability
- Prometheus API: `http://prometheus.openclaw.internal:9090/api/v1/`.
- Loki API: `http://loki.openclaw.internal:3100/loki/api/v1/`.
- Grafana API: `https://grafana.openclaw.internal/api/`.

For full agent API documentation, refer to the upstream OpenClaw runtime repository once published.
