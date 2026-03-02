# PKI Scripts

All certificates are rooted in the gentoofoo.com internal CA. This directory contains helper scripts to generate the root, intermediate, and leaf certificates. **Never commit private keys or generated certificates to version control.**

## Files
- `root-ca/gen_root.sh` – creates the gentoofoo root CA key and certificate using OpenSSL.
- `root-ca/openssl.cnf` – baseline config for the root CA.
- `issuing-ca/gen_intermediate.sh` – builds the intermediate CA CSR and signs it with the root.
- `issuing-ca/openssl.cnf` – config for the issuing CA.
- `issue_cert.sh` – convenience wrapper to issue server/client certificates signed by the intermediate CA.

## Usage
1. Generate root CA:
   ```bash
   cd pkis/root-ca
   ./gen_root.sh
   ```
2. Generate intermediate:
   ```bash
   cd ../issuing-ca
   ./gen_intermediate.sh
   ```
3. Issue service cert:
   ```bash
   ../issue_cert.sh gateway.openclaw.internal "DNS:gateway.openclaw.internal,IP:10.31.0.5" server
   ```
4. Issue client cert:
   ```bash
   ../issue_cert.sh operator1 "DNS:operator1.openclaw.internal" client
   ```
5. Import certs into Vault or copy to service directories as needed.

Store private materials (keys, generated certs, PKCS#12 bundles) in a secure secrets manager or offline medium.
