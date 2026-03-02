#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."

if [[ $# -lt 3 ]]; then
  echo "Usage: $0 <common_name> <sans> <server|client>" >&2
  exit 1
fi

pkis/issue_cert.sh "$1" "$2" "$3"
