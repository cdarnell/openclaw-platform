# Health Check Playbook

OpenClaw ships with a `tests/health-check.sh` script and cron sample for continuous validation. This document explains what to monitor and how to interpret failures.

## Targets
1. **WireGuard Tunnel** – Verify peer handshake timestamps and data counters.
2. **OpenClaw Gateway** – HTTPS `/health` endpoint over WireGuard IP with mTLS.
3. **n8n** – `GET /rest/health` via WireGuard.
4. **Vault** – `GET /v1/sys/health` (expect `sealed=false`, `initialized=true`).
5. **Observability** – Prometheus target status endpoint (optional) to ensure metrics pipeline is alive.

## Running Checks
```bash
cd /opt/openclaw-platform/tests
./health-check.sh --config ./health-check.conf
```
The script exits non-zero if any component is unhealthy. Configure cron (see `tests/cron/health-check.cron`) to run every 5 minutes and log to `/var/log/openclaw/health.log`.

## Alerting
- Forward cron output to Loki via Vector or use Prometheus Alertmanager to fire notifications when targets go `DOWN` for longer than a threshold.
- Grafana dashboards include a panel summarizing health check results.

## Troubleshooting Tips
- **WireGuard down**: run `sudo wg show`; check OCI security list (`51820/udp`) and on-prem firewall.
- **OpenClaw/n8n unreachable**: ensure containers are running (`docker compose ps`), certs valid, Vault reachable.
- **Vault sealed**: unseal with stored keys; then investigate why it sealed (reboot, crash).
- **Observability silent**: confirm Prometheus service and `prometheus.yml` target definitions.

## Escalation
1. Review logs under `observability/` (Loki via Grafana) for the impacted service.
2. Re-run `tests/health-check.sh -v` for verbose output.
3. Reboot specific services (`docker compose restart <service>`).
4. Failing that, consult runbooks for certificate rotation or Vault recovery.
