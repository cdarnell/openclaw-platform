# Certificate Rotation Runbook

Regularly rotating certificates reduces exposure if keys are compromised. This runbook assumes you are using Vault’s PKI engine backed by the gentoofoo root CA.

## Schedule
- **Intermediate CA**: every 12 months (or sooner if policy dictates).
- **Service/Client Certificates**: every 30 days (default TTL is 30 days; renew automatically).

## Prerequisites
- Admin access to Vault.
- Access to the repository (for reference configs) and to the OCI host.
- Communication plan with operators to install new client certs.

## Steps (Service Certificates)
1. **Identify expiring certs** using Vault leases:
   ```bash
   vault list sys/leases/lookup/gentoofoo-int/issue/openclaw-server
   ```
2. **Renew** automatically (preferred):
   - Services call Vault’s `/v1/gentoofoo-int/issue/openclaw-server` endpoint during startup.
   - Use systemd timers or cron to trigger a small script that requests a new cert and reloads the service.
3. **Manual rotation**:
   ```bash
   vault write gentoofoo-int/issue/openclaw-server common_name="gateway.openclaw.internal" alt_names="DNS:gateway.openclaw.internal,IP:10.31.0.5"
   ```
4. **Deploy** the new cert/key pair to the container volume (replace files, restart container).

## Steps (Client Certificates)
1. Issue new certs via `platform/scripts/issue-service-cert.sh` (works for clients as well).
2. Distribute the `.pfx` or PEM bundle to operators through a secure channel.
3. Revoke old certs if needed:
   ```bash
   vault write gentoofoo-int/revoke serial_number="<serial>"
   ```
4. Update CRL (`vault write gentoofoo-int/config/urls crl_distribution_points="https://vault.gentoofoo.internal/v1/gentoofoo-int/crl"`).

## Intermediate Rotation
1. Generate new CSR from `pkis/issuing-ca/gen_intermediate.sh`.
2. Sign with root CA using Vault or offline process.
3. Update Vault intermediate path with new certificate.
4. Redeploy CA bundle to services.

## Validation
- Use `openssl s_client -connect <service>:<port> -CAfile gentoofoo-chain.pem` to confirm the new cert is served.
- Check Prometheus alerts for expired/expiring certificates.

## Rollback
- Keep previous cert/key pair for a short window; if the new cert breaks clients, revert files and restart the service while you troubleshoot.

Document each rotation in your change log and ensure unseal keys/root tokens used during the process are stored securely.
