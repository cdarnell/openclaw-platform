# OCI Host Preparation

This guide preps an Ubuntu-based OCI instance to run the OpenClaw platform.

## Prerequisites
- OCI tenancy with permissions to create compute instances and security list rules.
- Ubuntu 22.04 or 24.04 image (Ampere or AMD64).
- gentoofoo CA material stored securely elsewhere.

## Steps

1. **Provision VM**
   - Shape: `VM.Standard.A1.Flex` (Ampere) or `VM.Standard3.Flex` (x86) with at least 4 OCPUs / 16 GB RAM.
   - Storage: 200 GB block volume (provides headroom for Loki + backups).
   - VCN/Security List: open inbound `22/tcp` (SSH), `51820/udp` (WireGuard), and optional ports for observability if remote access is required.

2. **SSH In**
   ```bash
   ssh -i ~/.ssh/openclaw-oci.key ubuntu@<public-ip>
   ```

3. **Run bootstrap script**
   ```bash
   sudo apt update && sudo apt install -y git
   git clone https://github.com/<your-org>/openclaw-platform.git
   cd openclaw-platform/infra/scripts
   sudo ./bootstrap-oci.sh
   ```
   The script installs Docker, Docker Compose plugin, WireGuard tools, Vault binary, Node.js 20 (for n8n tooling), and sets up baseline firewall rules.

4. **Create deploy user (optional)**
   ```bash
   sudo adduser openclaw
   sudo usermod -aG sudo,docker openclaw
   sudo cp -r ~/.ssh /home/openclaw/
   sudo chown -R openclaw:openclaw /home/openclaw/.ssh
   ```

5. **Clone repo for deploy user**
   ```bash
   sudo -u openclaw git clone https://github.com/<your-org>/openclaw-platform.git /opt/openclaw-platform
   ```

6. **Persist system settings**
   - Enable IP forwarding: add `net.ipv4.ip_forward=1` and `net.ipv6.conf.all.forwarding=1` to `/etc/sysctl.d/99-openclaw.conf`, then `sudo sysctl --system`.
   - Allow WireGuard service through firewall (handled in bootstrap script, but verify):
     ```bash
     sudo ufw allow 51820/udp
     sudo ufw reload
     ```

7. **Next steps**
   - Generate PKI (`pkis/`).
   - Configure WireGuard (`platform/configs/wireguard/`).
   - Deploy the platform via `platform/scripts/deploy.sh`.

See `docs/setup/wireguard.md` and `docs/setup/vault.md` for continued configuration.
