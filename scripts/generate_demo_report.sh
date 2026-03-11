#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ENV_FILE="${ENV_FILE:-.env}"
if [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
fi

MODE="${1:-testnet}"
TEMPLATE="${2:-all}"
ACTION="${3:-report}"
OUTPUT_FILE="${OUTPUT_FILE:-docs/demo-proof.md}"

if ! command -v jq >/dev/null 2>&1; then
  echo "[demo-proof] ERROR: jq is required" >&2
  exit 1
fi

case "$MODE" in
  local)
    RPC_URL="${LOCAL_RPC_URL:-http://127.0.0.1:8545}"
    CHAIN_ID="${LOCAL_CHAIN_ID:-31337}"
    EXPLORER_PREFIX="${LOCAL_EXPLORER_PREFIX:-http://localhost:8545/tx/}"
    ;;
  testnet)
    RPC_URL="${RPC_URL:-${SEPOLIA_RPC_URL:-}}"
    CHAIN_ID="${CHAIN_ID:-${SEPOLIA_CHAIN_ID:-1301}}"
    EXPLORER_PREFIX="${EXPLORER_PREFIX:-https://sepolia.uniscan.xyz/tx/}"
    if [[ -z "$RPC_URL" ]]; then
      echo "[demo-proof] ERROR: set RPC_URL (or SEPOLIA_RPC_URL) for testnet mode" >&2
      exit 1
    fi
    ;;
  *)
    echo "[demo-proof] ERROR: mode must be local or testnet" >&2
    exit 1
    ;;
esac

if [[ "$TEMPLATE" != "stable" && "$TEMPLATE" != "rwa" && "$TEMPLATE" != "longtail" && "$TEMPLATE" != "all" ]]; then
  echo "[demo-proof] ERROR: template must be stable|rwa|longtail|all" >&2
  exit 1
fi

if [[ "$ACTION" != "auto" && "$ACTION" != "deploy" && "$ACTION" != "report" ]]; then
  echo "[demo-proof] ERROR: action must be auto|deploy|report" >&2
  exit 1
fi

TOPIC_GUARD="0xeb0420399a638d792a772732f193aa885229c98fbcb1f6c3272f58338b0872f1"
TOPIC_FEE="0x8da4d3b66302c5920804ac4d42493a89f6bb8801a3ffeb19b5d489d5c621712c"
TOPIC_MODE="0xee49ba7b0007a0d09113a918ea47ac666b00320118876c292bdbb228b469d656"
TOPIC_CONFIG="0x6c0832b3cb2f7cd7900aa926c2ff6dc61cb623d7661818ec294730147c7a9fda"
TOPIC_TEMPLATE_DEPLOYED="0xc0dc2c90eb52a4772beee901ae3876514e28de4a8604ee920b75394876ade256"

template_label() {
  case "$1" in
    stable) echo "Stablecoin Template" ;;
    rwa) echo "RWA Template" ;;
    longtail) echo "Long-Tail Template" ;;
    *) echo "$1" ;;
  esac
}

script_for_template() {
  case "$1" in
    stable) echo "script/DemoStablecoin.s.sol" ;;
    rwa) echo "script/DemoRWA.s.sol" ;;
    longtail) echo "script/DemoLongTail.s.sol" ;;
    *) echo "" ;;
  esac
}

run_file_for_template() {
  local script_path="$1"
  local script_base
  local direct_path
  local nested_path

  script_base="$(basename "$script_path")"
  direct_path="broadcast/${script_base}/${CHAIN_ID}/run-latest.json"
  nested_path="broadcast/${script_path}/${CHAIN_ID}/run-latest.json"
  if [[ -f "$direct_path" ]]; then
    echo "$direct_path"
  else
    echo "$nested_path"
  fi
}

tx_link() {
  local tx_hash="${1:-}"
  if [[ -z "$tx_hash" || "$tx_hash" == "null" ]]; then
    echo "N/A"
  else
    echo "[${tx_hash}](${EXPLORER_PREFIX}${tx_hash})"
  fi
}

json_first() {
  local query="$1"
  local file="$2"
  jq -r "$query" "$file"
}

TMP_LOG="$(mktemp)"
trap 'rm -f "$TMP_LOG"' EXIT
bash scripts/demo_e2e.sh "$MODE" "$TEMPLATE" "$ACTION" | tee "$TMP_LOG"

templates_to_run="$TEMPLATE"
if [[ "$TEMPLATE" == "all" ]]; then
  templates_to_run="stable rwa longtail"
fi

mkdir -p "$(dirname "$OUTPUT_FILE")"

{
  echo "# Demo Proof Report"
  echo ""
  echo "- Generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
  echo "- Mode: \`$MODE\`"
  echo "- Chain ID: \`$CHAIN_ID\`"
  echo "- RPC: \`$RPC_URL\`"
  echo "- Explorer Prefix: \`$EXPLORER_PREFIX\`"
  echo "- Command: \`bash scripts/generate_demo_report.sh $MODE $TEMPLATE $ACTION\`"
  echo ""
  echo "## End-to-End Workflow (User Perspective)"
  echo "1. User selects template profile (Stablecoin / RWA / Long-Tail)."
  echo "2. User enters market policy config (fees, guardrails, launch/session limits)."
  echo "3. Runner deploys hook + execution stack and initializes liquidity on canonical PoolManager."
  echo "4. Demo swaps execute and core hook functions run (\`beforeSwap\`/\`afterSwap\`)."
  echo "5. Script prints transaction hashes and explorer URLs."
  echo "6. Script inspects receipts and reports standardized event proofs."
  echo ""
  echo "## Deployment Summary"

  for template in $templates_to_run; do
    script_path="$(script_for_template "$template")"
    run_file="$(run_file_for_template "$script_path")"

    echo ""
    echo "### $(template_label "$template")"
    echo "- Broadcast File: \`$run_file\`"

    if [[ ! -f "$run_file" ]]; then
      echo "- Status: missing broadcast file"
      continue
    fi

    deployer="$(json_first '.transactions[0].transaction.from // "N/A"' "$run_file")"
    pool_manager="$(json_first '[.transactions[] | select(.contractName == "PoolManager" and .transactionType == "CREATE") | .contractAddress] | .[0] // ""' "$run_file")"
    if [[ -z "$pool_manager" ]]; then
      pool_manager="$(json_first '[.transactions[] | select((.function // "") | startswith("initialize(")) | .contractAddress] | .[0] // "N/A"' "$run_file")"
    fi
    swap_router="$(json_first '[.transactions[] | select(.contractName == "PoolSwapTest" and .transactionType == "CREATE") | .contractAddress] | .[0] // "N/A"' "$run_file")"
    liquidity_router="$(json_first '[.transactions[] | select(.contractName == "PoolModifyLiquidityTest" and .transactionType == "CREATE") | .contractAddress] | .[0] // "N/A"' "$run_file")"
    token0="$(json_first '[.transactions[] | select(.contractName == "MockERC20" and .transactionType == "CREATE") | .contractAddress] | .[0] // "N/A"' "$run_file")"
    token1="$(json_first '[.transactions[] | select(.contractName == "MockERC20" and .transactionType == "CREATE") | .contractAddress] | .[1] // "N/A"' "$run_file")"
    hook_address="$(json_first '[.transactions[] | select((.contractName // "" | test("TemplateHook$")) and ((.transactionType // "") | test("^CREATE"))) | .contractAddress] | .[0] // "N/A"' "$run_file")"

    hook_deploy_tx="$(json_first '[.transactions[] | select((.contractName // "" | test("TemplateHook$")) and ((.transactionType // "") | test("^CREATE"))) | .hash] | .[0] // ""' "$run_file")"
    pool_init_tx="$(json_first '[.transactions[] | select((.function // "") | startswith("initialize(")) | .hash] | .[0] // ""' "$run_file")"
    liquidity_tx="$(json_first '[.transactions[] | select((.function // "") | startswith("modifyLiquidity(")) | .hash] | .[0] // ""' "$run_file")"
    swap_tx_1="$(json_first '[.transactions[] | select((.function // "") | startswith("swap(")) | .hash] | .[0] // ""' "$run_file")"
    swap_tx_2="$(json_first '[.transactions[] | select((.function // "") | startswith("swap(")) | .hash] | .[1] // ""' "$run_file")"
    swap_tx_3="$(json_first '[.transactions[] | select((.function // "") | startswith("swap(")) | .hash] | .[2] // ""' "$run_file")"

    guard_count="$(jq -r --arg t "$TOPIC_GUARD" '[.receipts[]?.logs[]? | select((.topics[0] // "" | ascii_downcase) == ($t | ascii_downcase))] | length' "$run_file")"
    fee_count="$(jq -r --arg t "$TOPIC_FEE" '[.receipts[]?.logs[]? | select((.topics[0] // "" | ascii_downcase) == ($t | ascii_downcase))] | length' "$run_file")"
    mode_count="$(jq -r --arg t "$TOPIC_MODE" '[.receipts[]?.logs[]? | select((.topics[0] // "" | ascii_downcase) == ($t | ascii_downcase))] | length' "$run_file")"
    config_count="$(jq -r --arg t "$TOPIC_CONFIG" '[.receipts[]?.logs[]? | select((.topics[0] // "" | ascii_downcase) == ($t | ascii_downcase))] | length' "$run_file")"
    deployed_count="$(jq -r --arg t "$TOPIC_TEMPLATE_DEPLOYED" '[.receipts[]?.logs[]? | select((.topics[0] // "" | ascii_downcase) == ($t | ascii_downcase))] | length' "$run_file")"

    echo "- Deployer: \`$deployer\`"
    echo "- PoolManager: \`$pool_manager\`"
    echo "- Hook: \`$hook_address\`"
    echo "- Swap Router: \`$swap_router\`"
    echo "- Liquidity Router: \`$liquidity_router\`"
    echo "- Token0: \`$token0\`"
    echo "- Token1: \`$token1\`"
    echo "- Hook Deploy Tx: $(tx_link "$hook_deploy_tx")"
    echo "- Pool Init Tx: $(tx_link "$pool_init_tx")"
    echo "- Liquidity Tx: $(tx_link "$liquidity_tx")"
    echo "- Swap Tx 1: $(tx_link "$swap_tx_1")"
    echo "- Swap Tx 2: $(tx_link "$swap_tx_2")"
    echo "- Swap Tx 3: $(tx_link "$swap_tx_3")"
    echo "- Event Counts: GuardTriggered=$guard_count FeeUpdated=$fee_count ModeTransitioned=$mode_count ConfigUpdated=$config_count TemplateDeployed=$deployed_count"
  done

  echo ""
  echo "## Raw Demo Runner Output"
  echo '```text'
  cat "$TMP_LOG"
  echo '```'
} > "$OUTPUT_FILE"

echo "[demo-proof] wrote $OUTPUT_FILE"
