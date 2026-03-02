path "gentoofoo-int/issue/openclaw-server" {
  capabilities = ["create", "update"]
}

path "secret/data/openclaw/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
