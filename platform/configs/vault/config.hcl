listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_cert_file = "/certs/vault-fullchain.pem"
  tls_key_file  = "/certs/vault.key"
}

storage "file" {
  path = "/vault/file"
}

disable_mlock = true
cluster_addr  = "https://vault.openclaw.internal:8201"
api_addr      = "https://vault.openclaw.internal:8200"
