#!/usr/bin/env bash
set -euo pipefail

TEMPLATE="${1:-all}"
RPC_URL="${RPC_URL:?set RPC_URL for testnet demo}"
PRIVATE_KEY="${PRIVATE_KEY:?set PRIVATE_KEY for testnet demo}"
CHAIN_ID="${CHAIN_ID:-84532}"
EXPLORER_PREFIX="${EXPLORER_PREFIX:-https://sepolia.basescan.org/tx/}"

run_template() {
  local name="$1"
  local script_file="$2"

  echo "[demo-testnet] Running ${name} demo on chain ${CHAIN_ID}"
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
