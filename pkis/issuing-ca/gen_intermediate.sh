#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(dirname "$0")"
ROOT_DIR="${SCRIPT_DIR}/.."
DIST_DIR="${ROOT_DIR}/dist"
mkdir -p "$DIST_DIR"

if [[ ! -f ${ROOT_DIR}/root-ca/root-ca.pem ]]; then
  echo "[!] Missing root CA. Run pkis/root-ca/gen_root.sh first." >&2
  exit 1
fi

cd "$SCRIPT_DIR"

echo "[*] Generating issuing CA key and CSR"
openssl genrsa -out issuing-ca.key 4096
openssl req -new -key issuing-ca.key -out issuing-ca.csr -config openssl.cnf

echo "[*] Signing issuing CA with root"
openssl x509 -req -in issuing-ca.csr \
  -CA ../root-ca/root-ca.pem -CAkey ../root-ca/root-ca.key -CAcreateserial \
  -out issuing-ca.pem -days 1825 -sha256 -extfile openssl.cnf -extensions v3_req

cat issuing-ca.pem ../root-ca/root-ca.pem > "$DIST_DIR/gentoofoo-chain.pem"
cp issuing-ca.pem "$DIST_DIR/gentoofoo-issuing.pem"
cp issuing-ca.key "$DIST_DIR/gentoofoo-issuing.key"

echo "[+] Issuing CA ready"
