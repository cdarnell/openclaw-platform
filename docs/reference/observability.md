# Observability Reference

This document enumerates the dashboards, data sources, and key metrics included with the OpenClaw observability stack.

## Data Sources
| Name | Type | URL |
|------|------|-----|
| `Prometheus` | Prometheus | `http://prometheus:9090` (inside Docker network) |
| `Loki` | Loki | `http://loki:3100` |

## Dashboards
1. **OpenClaw Overview** (`observability/grafana/dashboards/openclaw-overview.json`)
   - Gateway/planner/executor latencies
   - Task throughput and error rate
   - Vault and n8n health summaries
2. **WireGuard Health** (`observability/grafana/dashboards/wireguard-health.json`)
   - Peer handshakes, transfer stats, keep-alive intervals
   - Alerts when tunnel is down or data rate spikes
3. **Vault Status** (`observability/grafana/dashboards/vault-status.json`)
   - Seal status, HA mode, request latency, unseal progress
4. **Host Metrics** (node exporter + cAdvisor)
   - CPU, memory, disk, network for the OCI host and containers

## Prometheus Targets
- `openclaw_gateway` – scraped over WireGuard IP (custom metrics endpoint or via exporter)
- `openclaw_planner`
- `openclaw_executor`
- `n8n`
- `vault`
- `wireguard_exporter` (optional)
- `node_exporter`
- `cadvisor`

## Loki Labels
Vector attaches the following labels to log streams:
- `service` – docker compose service name (`gateway`, `n8n`, `vault`, etc.)
- `container` – container ID
- `level` – derived from log line parsing (info/warn/error)
- `job` – `openclaw`

## Alerts
Integrate Grafana Alerting or Alertmanager with:
- **WireGuardDown** – no handshake in 5 minutes.
- **VaultSealed** – `vault_unsealed == 0` for >1 minute.
- **OpenClawTaskErrors** – error rate above threshold.
- **DiskPressure** – <15% free space on `/var/lib/docker`.

Refer to `observability/README.md` (todo) for deployment and customization guidance.
