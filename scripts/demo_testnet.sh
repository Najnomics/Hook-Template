#!/usr/bin/env bash
set -euo pipefail

TEMPLATE="${1:-all}"
ACTION="${2:-auto}"

bash scripts/demo_e2e.sh testnet "$TEMPLATE" "$ACTION"
