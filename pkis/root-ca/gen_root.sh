#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

mkdir -p ../dist

if [[ -f root-ca.key || -f root-ca.pem ]]; then
  echo "[!] Root CA already exists. Remove files manually to regenerate." >&2
  exit 1
fi

echo "[*] Generating GentooFoo root CA"
openssl genrsa -out root-ca.key 4096
openssl req -x509 -new -nodes -key root-ca.key \
  -sha384 -days 3650 -out root-ca.pem -config openssl.cnf

cp root-ca.pem ../dist/gentoofoo-root.pem
cp root-ca.key ../dist/gentoofoo-root.key

echo "[+] Root CA generated: root-ca.pem"
