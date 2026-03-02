#!/usr/bin/env bash
set -euo pipefail
CMD=${1:-help}
shift || true
case "$CMD" in
  issue-cert)
    ./pkis/issue_cert.sh "$@"
    ;;
  deploy-platform)
    ./platform/scripts/deploy.sh
    ;;
  deploy-observability)
    ./observability/scripts/deploy.sh
    ;;
  health-check)
    ./tests/health-check.sh ./tests/health-check.conf
    ;;
  *)
    cat <<'EOF'
Usage: ./scripts/cli.sh <command>
  issue-cert <cn> <sans> <server|client>
  deploy-platform
  deploy-observability
  health-check
EOF
    ;;
esac
