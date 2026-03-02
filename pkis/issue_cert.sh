#!/usr/bin/env bash
set -euo pipefail
if [[ $# -lt 3 ]]; then
  echo "Usage: $0 <common_name> <san_list> <profile(server|client)>" >&2
  exit 1
fi
CN="$1"
SANS="$2"
PROFILE="$3"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ISSUER_DIR="$SCRIPT_DIR/issuing-ca"
DIST_DIR="$SCRIPT_DIR/dist"
mkdir -p "$DIST_DIR"

case "$PROFILE" in
  server) EXT="extendedKeyUsage = serverAuth" ;;
  client) EXT="extendedKeyUsage = clientAuth" ;;
  *) echo "Profile must be server or client" >&2; exit 1;;
esac

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

cat > "$TMP_DIR/req.cnf" <<EOF
[ req ]
prompt = no
default_bits = 4096
default_md = sha256
distinguished_name = dn
req_extensions = v3_req

[ dn ]
CN = ${CN}

[ v3_req ]
subjectAltName = ${SANS}
keyUsage = digitalSignature, keyEncipherment
${EXT}
EOF

openssl genrsa -out "$TMP_DIR/${CN}.key" 4096
openssl req -new -key "$TMP_DIR/${CN}.key" -out "$TMP_DIR/${CN}.csr" -config "$TMP_DIR/req.cnf"

openssl x509 -req -in "$TMP_DIR/${CN}.csr" \
  -CA "$ISSUER_DIR/issuing-ca.pem" -CAkey "$ISSUER_DIR/issuing-ca.key" -CAcreateserial \
  -out "$TMP_DIR/${CN}.pem" -days 90 -sha256 -extfile "$TMP_DIR/req.cnf" -extensions v3_req

cat "$TMP_DIR/${CN}.pem" "$ISSUER_DIR/../root-ca/root-ca.pem" > "$DIST_DIR/${CN}-fullchain.pem"
cp "$TMP_DIR/${CN}.key" "$DIST_DIR/${CN}.key"
cp "$TMP_DIR/${CN}.pem" "$DIST_DIR/${CN}.pem"

echo "Issued certificate saved under $DIST_DIR/${CN}*.pem"
