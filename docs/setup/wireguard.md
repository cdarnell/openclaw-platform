# WireGuard Configuration

WireGuard secures all communication between the OCI host and on-prem peers (Ollama cluster, operator laptops, etc.).

## Network Plan
- Tunnel subnet: `10.31.0.0/24`
- OCI server (interface `wg0`): `10.31.0.1`
- On-prem Ollama host: `10.31.0.10`
- Operator laptops: assigned from `10.31.0.100+`

Adjust the subnet to fit your environment, but keep it isolated from existing networks.

## Server Setup (OCI)

1. Generate keys:
   ```bash
   umask 077
   wg genkey | tee /etc/wireguard/server.key | wg pubkey > /etc/wireguard/server.pub
   ```

2. Edit `platform/configs/wireguard/server.conf` with:
   - `[Interface]` private key, address (`10.31.0.1/24`), listen port (`51820`), PostUp/PostDown iptables rules for NAT if needed.
   - `[Peer]` blocks for each client (public key, allowed IPs, persistent keepalive).

3. Apply configuration:
   ```bash
   sudo cp platform/configs/wireguard/server.conf /etc/wireguard/wg0.conf
   sudo systemctl enable wg-quick@wg0
   sudo systemctl start wg-quick@wg0
   ```

4. Verify:
   ```bash
   sudo wg show
   ```

## Client Setup (On-Prem / Operator)

1. Generate keys on each client:
   ```bash
   umask 077
   wg genkey | tee client.key | wg pubkey > client.pub
   ```

2. Copy `platform/configs/wireguard/client-template.conf` and fill in:
   - `[Interface]` private key, client tunnel IP (for example `10.31.0.10/32`).
   - `[Peer]` public key of OCI server, endpoint `<oci-public-ip>:51820`, allowed IPs (`10.31.0.0/24` plus on-prem networks you want to reach), keepalive 25.

3. Send the client’s public key + desired IP to the OCI server and add a `[Peer]` entry in `server.conf`.

4. Start WireGuard on the client (commands vary by OS):
   ```bash
   sudo wg-quick up wg-oci
   ```

5. Test connectivity to OCI services via `ping 10.31.0.1` and `curl https://<service> --cacert gentoofoo-root.pem --cert client.pem`.

## Routing Ollama Traffic
- On the OCI server, add a route so requests for the Ollama LAN (for example `192.168.50.0/24`) go through the WireGuard peer IP of your on-prem gateway.
- On the on-prem router/gateway, add a reverse route so responses for the OCI subnet use the WireGuard tunnel.

## Security Tips
- Keep private keys off GitHub; store them in Vault or a secure password manager.
- Rotate WireGuard keys periodically.
- Use firewall rules (UFW or iptables) to restrict WireGuard traffic to expected IPs and ports.
- Monitor `wg show` output for unexpected peers or data spikes.
