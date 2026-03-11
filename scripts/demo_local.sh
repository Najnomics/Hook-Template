#!/usr/bin/env bash
set -euo pipefail

TEMPLATE="${1:-all}"
ACTION="${2:-deploy}"

bash scripts/demo_e2e.sh local "$TEMPLATE" "$ACTION"
