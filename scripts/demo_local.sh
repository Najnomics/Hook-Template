#!/usr/bin/env bash
set -euo pipefail

TEMPLATE="${1:-all}"
RPC_URL="${RPC_URL:-http://127.0.0.1:8545}"
PRIVATE_KEY="${PRIVATE_KEY:-0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80}"
CHAIN_ID="${CHAIN_ID:-31337}"
EXPLORER_PREFIX="${EXPLORER_PREFIX:-http://localhost:8545/tx/}"

run_template() {
  local name="$1"
  local script_file="$2"

  echo "[demo-local] Running ${name} demo"
  forge script "$script_file" --rpc-url "$RPC_URL" --private-key "$PRIVATE_KEY" --broadcast
  bash scripts/print_broadcast_txs.sh "$script_file" "$CHAIN_ID" "$EXPLORER_PREFIX"
}

case "$TEMPLATE" in
  stable)
    run_template "stablecoin" "script/DemoStablecoin.s.sol"
    ;;
  rwa)
    run_template "rwa" "script/DemoRWA.s.sol"
    ;;
  longtail)
    run_template "longtail" "script/DemoLongTail.s.sol"
    ;;
  all)
    run_template "stablecoin" "script/DemoStablecoin.s.sol"
    run_template "rwa" "script/DemoRWA.s.sol"
    run_template "longtail" "script/DemoLongTail.s.sol"
    ;;
  *)
    echo "unknown template '${TEMPLATE}' (expected: stable|rwa|longtail|all)" >&2
    exit 1
    ;;
esac
