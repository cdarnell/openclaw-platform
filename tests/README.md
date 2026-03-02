# Health Check Suite

- `health-check.sh` – Bash script that validates WireGuard, gateway, n8n, and Vault endpoints using mutual TLS.
- `health-check.conf` – Configuration file providing certificate paths and hostnames.
- `cron/health-check.cron` – Example crontab entry to run the check every 5 minutes.

## Usage
```bash
cd /opt/openclaw-platform/tests
./health-check.sh ./health-check.conf
```
Set up cron:
```bash
crontab cron/health-check.cron
```
Logs are appended to `/var/log/openclaw/health.log` (create directory and set permissions first).
