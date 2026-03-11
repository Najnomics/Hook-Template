#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

CHAIN_ID="${CHAIN_ID:-1301}"
EXPLORER_PREFIX="${EXPLORER_PREFIX:-https://sepolia.uniscan.xyz/tx/}"
OUTPUT_FILE="${OUTPUT_FILE:-docs/deployments.md}"

if ! command -v jq >/dev/null 2>&1; then
  echo "[deployments-md] ERROR: jq is required" >&2
  exit 1
fi

template_label() {
  case "$1" in
    stable) echo "Stablecoin Template" ;;
    rwa) echo "RWA Template" ;;
    longtail) echo "Long-Tail Template" ;;
    *) echo "$1" ;;
  esac
}

script_file_for() {
  case "$1" in
    stable) echo "DemoStablecoin.s.sol" ;;
    rwa) echo "DemoRWA.s.sol" ;;
    longtail) echo "DemoLongTail.s.sol" ;;
    *) echo "" ;;
  esac
}

tx_link() {
  local tx_hash="$1"
  if [[ -z "$tx_hash" || "$tx_hash" == "null" ]]; then
    echo "N/A"
  else
    echo "[${tx_hash}](${EXPLORER_PREFIX}${tx_hash})"
  fi
}

{
  echo "# Deployments (Unichain Sepolia)"
  echo ""
  echo "Network: \`Unichain Sepolia\`  "
  echo "Chain ID: \`${CHAIN_ID}\`  "
  echo "Explorer: \`${EXPLORER_PREFIX}\`"
  echo ""
  echo "Generated from latest broadcast artifacts."
  echo ""

  for template in stable rwa longtail; do
    script_file="$(script_file_for "$template")"
    run_file="broadcast/${script_file}/${CHAIN_ID}/run-latest.json"

    echo "## $(template_label "$template")"
    echo ""
    echo "Source: \`${run_file}\`"
    echo ""

    if [[ ! -f "$run_file" ]]; then
      echo "_Missing run file_"
      echo ""
      continue
    fi

    echo "| Component | Address | Deploy Tx |"
    echo "|---|---|---|"

    pool_manager="$(jq -r '[.transactions[] | select((.function // "") | startswith("initialize(")) | .contractAddress] | .[0] // empty' "$run_file")"
    if [[ -n "$pool_manager" ]]; then
      echo "| PoolManager (Canonical) | \`${pool_manager}\` | Predeployed on Unichain (external to this script run) |"
    fi

    jq -r '.transactions[]
      | select((.transactionType // "") | test("^CREATE"))
      | [.contractName, .contractAddress, .hash]
      | @tsv' "$run_file" \
      | while IFS=$'\t' read -r contract_name contract_address tx_hash; do
          echo "| ${contract_name} | \`${contract_address}\` | $(tx_link "$tx_hash") |"
        done

    echo ""
    echo "Lifecycle txs:"

    if [[ "$template" == "rwa" ]]; then
      allowlist_tx="$(jq -r '[.transactions[] | select((.function // "") | startswith("setAllowlist(")) | .hash] | .[0] // empty' "$run_file")"
      if [[ -n "$allowlist_tx" ]]; then
        echo "- Hook allowlist setup: $(tx_link "$allowlist_tx")"
      fi
    fi

    init_tx="$(jq -r '[.transactions[] | select((.function // "") | startswith("initialize(")) | .hash] | .[0] // empty' "$run_file")"
    liq_tx="$(jq -r '[.transactions[] | select((.function // "") | startswith("modifyLiquidity(")) | .hash] | .[0] // empty' "$run_file")"
    swap1_tx="$(jq -r '[.transactions[] | select((.function // "") | startswith("swap(")) | .hash] | .[0] // empty' "$run_file")"
    swap2_tx="$(jq -r '[.transactions[] | select((.function // "") | startswith("swap(")) | .hash] | .[1] // empty' "$run_file")"
    swap3_tx="$(jq -r '[.transactions[] | select((.function // "") | startswith("swap(")) | .hash] | .[2] // empty' "$run_file")"

    echo "- Pool initialize: $(tx_link "$init_tx")"
    echo "- Add liquidity: $(tx_link "$liq_tx")"
    echo "- Swap 1: $(tx_link "$swap1_tx")"
    echo "- Swap 2: $(tx_link "$swap2_tx")"
    echo "- Swap 3: $(tx_link "$swap3_tx")"
    echo ""
  done
} > "$OUTPUT_FILE"

echo "[deployments-md] wrote ${OUTPUT_FILE}"
