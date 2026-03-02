#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Run as root" >&2
  exit 1
fi

apt update
apt install -y ca-certificates curl gnupg lsb-release software-properties-common jq unzip git ufw

# Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --yes --dearmor -o /usr/share/keyrings/docker.gpg
add-apt-repository "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable --now docker

# WireGuard
apt install -y wireguard wireguard-tools

# Vault
VAULT_VERSION=1.17.3
curl -fsSL https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip -o /tmp/vault.zip
unzip /tmp/vault.zip -d /usr/local/bin
chmod +x /usr/local/bin/vault
useradd --system --home /etc/vault.d --shell /bin/false vault || true
mkdir -p /etc/vault.d
cat >/etc/systemd/system/vault.service <<'EOF'
[Unit]
Description=HashiCorp Vault
Requires=network-online.target
After=network-online.target

[Service]
User=vault
Group=vault
ProtectSystem=full
ProtectHome=read-only
ExecStart=/usr/local/bin/vault server -config=/etc/vault.d/vault.hcl
ExecReload=/bin/kill --signal HUP $MAINPID
KillMode=process
Restart=on-failure
LimitMEMLOCK=infinity
CapabilityBoundingSet=CAP_IPC_LOCK
AmbientCapabilities=CAP_IPC_LOCK

[Install]
WantedBy=multi-user.target
EOF

# Node.js 20 (for n8n tooling)
if ! command -v nvm >/dev/null; then
  su - ${SUDO_USER:-ubuntu} -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash"
fi

# Firewall baseline
ufw allow 22/tcp
ufw allow 51820/udp
ufw --force enable

sysctl -w net.ipv4.ip_forward=1
cat >/etc/sysctl.d/99-openclaw.conf <<'EOF'
net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1
EOF
sysctl --system

echo "Bootstrap complete"
