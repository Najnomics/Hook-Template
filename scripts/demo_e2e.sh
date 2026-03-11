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

MODE="${1:-local}"
TEMPLATE="${2:-all}"
ACTION="${3:-auto}"
UNICHAIN_SEPOLIA_CHAIN_ID="${UNICHAIN_SEPOLIA_CHAIN_ID:-1301}"

if ! command -v forge >/dev/null 2>&1; then
  echo "[demo-e2e] ERROR: forge is required" >&2
  exit 1
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "[demo-e2e] ERROR: jq is required" >&2
  exit 1
fi
if ! command -v cast >/dev/null 2>&1; then
  echo "[demo-e2e] ERROR: cast is required" >&2
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
      echo "[demo-e2e] ERROR: set RPC_URL (or SEPOLIA_RPC_URL) for testnet mode" >&2
      exit 1
    fi
    if [[ "$CHAIN_ID" != "$UNICHAIN_SEPOLIA_CHAIN_ID" ]]; then
      echo "[demo-e2e] ERROR: testnet mode is Unichain-only; CHAIN_ID must be $UNICHAIN_SEPOLIA_CHAIN_ID" >&2
      exit 1
    fi
    if [[ -z "${POOL_MANAGER_ADDRESS:-}" ]]; then
      echo "[demo-e2e] ERROR: POOL_MANAGER_ADDRESS is required in testnet mode" >&2
      exit 1
    fi
    rpc_chain_id="$(cast chain-id --rpc-url "$RPC_URL" 2>/dev/null || true)"
    if [[ -z "$rpc_chain_id" ]]; then
      echo "[demo-e2e] ERROR: failed to resolve chain-id from RPC_URL=$RPC_URL" >&2
      exit 1
    fi
    if [[ "$rpc_chain_id" != "$CHAIN_ID" ]]; then
      echo "[demo-e2e] ERROR: RPC chain-id ($rpc_chain_id) does not match CHAIN_ID ($CHAIN_ID)" >&2
      exit 1
    fi
    manager_code="$(cast code "$POOL_MANAGER_ADDRESS" --rpc-url "$RPC_URL" 2>/dev/null || true)"
    if [[ -z "$manager_code" || "$manager_code" == "0x" ]]; then
      echo "[demo-e2e] ERROR: POOL_MANAGER_ADDRESS=$POOL_MANAGER_ADDRESS has no deployed code on chain $CHAIN_ID" >&2
      exit 1
    fi
    ;;
  *)
    echo "[demo-e2e] ERROR: mode must be local or testnet" >&2
    exit 1
    ;;
esac

if [[ "$ACTION" != "auto" && "$ACTION" != "deploy" && "$ACTION" != "report" ]]; then
  echo "[demo-e2e] ERROR: action must be auto|deploy|report" >&2
  exit 1
fi

if [[ "$TEMPLATE" != "stable" && "$TEMPLATE" != "rwa" && "$TEMPLATE" != "longtail" && "$TEMPLATE" != "all" ]]; then
  echo "[demo-e2e] ERROR: template must be stable|rwa|longtail|all" >&2
  exit 1
fi

TOPIC_GUARD="0xeb0420399a638d792a772732f193aa885229c98fbcb1f6c3272f58338b0872f1"
TOPIC_FEE="0x8da4d3b66302c5920804ac4d42493a89f6bb8801a3ffeb19b5d489d5c621712c"
TOPIC_MODE="0xee49ba7b0007a0d09113a918ea47ac666b00320118876c292bdbb228b469d656"
TOPIC_CONFIG="0x6c0832b3cb2f7cd7900aa926c2ff6dc61cb623d7661818ec294730147c7a9fda"
TOPIC_TEMPLATE_DEPLOYED="0xc0dc2c90eb52a4772beee901ae3876514e28de4a8604ee920b75394876ade256"

upsert_env_var() {
  local key="$1"
  local value="$2"

  if [[ -z "$value" || "$value" == "null" ]]; then
    return 0
  fi

  if [[ ! -f "$ENV_FILE" ]]; then
    printf '%s=%s\n' "$key" "$value" > "$ENV_FILE"
    return 0
  fi

  if rg -q "^${key}=" "$ENV_FILE"; then
    awk -v k="$key" -v v="$value" '
      BEGIN { done = 0 }
      $0 ~ "^" k "=" { print k "=" v; done = 1; next }
      { print }
      END { if (!done) print k "=" v }
    ' "$ENV_FILE" > "$ENV_FILE.tmp"
    mv "$ENV_FILE.tmp" "$ENV_FILE"
  else
    printf '%s=%s\n' "$key" "$value" >> "$ENV_FILE"
  fi
}

script_for_template() {
  case "$1" in
    stable) echo "script/DemoStablecoin.s.sol" ;;
    rwa) echo "script/DemoRWA.s.sol" ;;
    longtail) echo "script/DemoLongTail.s.sol" ;;
    *)
      echo "" ;;
  esac
}

private_key_for_template() {
  case "$1" in
    stable)
      echo "${STABLE_PRIVATE_KEY:-${PRIVATE_KEY:-}}"
      ;;
    rwa)
      echo "${RWA_PRIVATE_KEY:-${PRIVATE_KEY:-}}"
      ;;
    longtail)
      echo "${LONGTAIL_PRIVATE_KEY:-${PRIVATE_KEY:-}}"
      ;;
    *)
      echo "${PRIVATE_KEY:-}"
      ;;
  esac
}

run_file_for_script() {
  local script_path="$1"
  local script_base
  local direct_path
  local nested_path

  script_base="$(basename "$script_path")"
  direct_path="broadcast/${script_base}/${CHAIN_ID}/run-latest.json"
  nested_path="broadcast/${script_path}/${CHAIN_ID}/run-latest.json"

  if [[ -f "$direct_path" ]]; then
    echo "$direct_path"
  elif [[ -f "$nested_path" ]]; then
    echo "$nested_path"
  else
    echo "$direct_path"
  fi
}

print_phase_header() {
  local template="$1"
  echo ""
  echo "[workflow][$template] Phase 1: user selects template and enters market policy parameters in the launcher"
  echo "[workflow][$template] Phase 2: deployer provisions hook + execution stack (routers, tokens, hook) on canonical PoolManager"
  echo "[workflow][$template] Phase 3: pool is initialized and seeded with liquidity"
  echo "[workflow][$template] Phase 4: scripted swaps execute to trigger template-specific hook logic"
  echo "[workflow][$template] Phase 5: receipts are analyzed for guard/fee/mode events and tx proofs"
}

print_tx_report() {
  local template="$1"
  local run_file="$2"

  local tx_count
  tx_count="$(jq -r '.transactions | length' "$run_file")"
  echo "[tx-report][$template] file=$run_file chain=$CHAIN_ID tx_count=$tx_count"

  jq -r '.transactions[] | [(.transaction.nonce // "-"), .transactionType, (.contractName // "-"), (.function // "-"), (.contractAddress // "-"), .hash] | @tsv' "$run_file" \
    | while IFS=$'\t' read -r nonce tx_type contract_name fn contract_addr tx_hash; do
        echo "[tx-report][$template] nonce=$nonce type=$tx_type contract=$contract_name function=$fn"
        if [[ "$contract_addr" != "-" && "$contract_addr" != "null" ]]; then
          echo "[tx-report][$template]   contractAddress=$contract_addr"
        fi
        echo "[tx-report][$template]   tx=$tx_hash"
        echo "[tx-report][$template]   explorer=${EXPLORER_PREFIX}${tx_hash}"
      done
}

print_event_report() {
  local template="$1"
  local run_file="$2"

  local guard_count
  local fee_count
  local mode_count
  local config_count
  local deployed_count

  guard_count="$(jq -r --arg t "$TOPIC_GUARD" '[.receipts[]?.logs[]? | select((.topics[0] // "" | ascii_downcase) == ($t | ascii_downcase))] | length' "$run_file")"
  fee_count="$(jq -r --arg t "$TOPIC_FEE" '[.receipts[]?.logs[]? | select((.topics[0] // "" | ascii_downcase) == ($t | ascii_downcase))] | length' "$run_file")"
  mode_count="$(jq -r --arg t "$TOPIC_MODE" '[.receipts[]?.logs[]? | select((.topics[0] // "" | ascii_downcase) == ($t | ascii_downcase))] | length' "$run_file")"
  config_count="$(jq -r --arg t "$TOPIC_CONFIG" '[.receipts[]?.logs[]? | select((.topics[0] // "" | ascii_downcase) == ($t | ascii_downcase))] | length' "$run_file")"
  deployed_count="$(jq -r --arg t "$TOPIC_TEMPLATE_DEPLOYED" '[.receipts[]?.logs[]? | select((.topics[0] // "" | ascii_downcase) == ($t | ascii_downcase))] | length' "$run_file")"

  echo "[events][$template] GuardTriggered=$guard_count FeeUpdated=$fee_count ModeTransitioned=$mode_count ConfigUpdated=$config_count TemplateDeployed=$deployed_count"

  jq -r --arg t "$TOPIC_GUARD" '.receipts[]?.logs[]? | select((.topics[0] // "" | ascii_downcase) == ($t | ascii_downcase)) | .transactionHash' "$run_file" \
    | sort -u \
    | while IFS= read -r tx_hash; do
        [[ -z "$tx_hash" ]] && continue
        echo "[events][$template] guardTx=$tx_hash url=${EXPLORER_PREFIX}${tx_hash}"
      done
}

persist_metadata() {
  local template="$1"
  local run_file="$2"

  local mode_key
  local template_key
  local prefix
  local hook_address
  local hook_tx
  local pool_manager
  local swap_router
  local liquidity_router
  local pool_key_tuple
  local pool_key_token0
  local pool_key_token1
  local pool_key_hook
  local token0
  local token1
  local pool_init_tx
  local liquidity_tx
  local swap1
  local swap2
  local swap3
  local deployer

  mode_key="$(echo "$MODE" | tr '[:lower:]' '[:upper:]')"
  template_key="$(echo "$template" | tr '[:lower:]' '[:upper:]')"
  prefix="${mode_key}_${template_key}"

  hook_address="$(jq -r '[.transactions[] | select((.contractName // "" | test("TemplateHook$")) and ((.transactionType // "") | test("^CREATE"))) | .contractAddress] | .[0] // empty' "$run_file")"
  hook_tx="$(jq -r '[.transactions[] | select((.contractName // "" | test("TemplateHook$")) and ((.transactionType // "") | test("^CREATE"))) | .hash] | .[0] // empty' "$run_file")"
  pool_manager="$(jq -r '[.transactions[] | select(.contractName == "PoolManager" and .transactionType == "CREATE") | .contractAddress] | .[0] // empty' "$run_file")"
  if [[ -z "$pool_manager" ]]; then
    pool_manager="$(jq -r '[.transactions[] | select((.function // "") | startswith("initialize(")) | .contractAddress] | .[0] // empty' "$run_file")"
  fi
  swap_router="$(jq -r '[.transactions[] | select(.contractName == "PoolSwapTest" and .transactionType == "CREATE") | .contractAddress] | .[0] // empty' "$run_file")"
  liquidity_router="$(jq -r '[.transactions[] | select(.contractName == "PoolModifyLiquidityTest" and .transactionType == "CREATE") | .contractAddress] | .[0] // empty' "$run_file")"
  pool_key_tuple="$(jq -r '[.transactions[] | select((.function // "") | startswith("initialize(")) | .arguments[0]] | .[0] // empty' "$run_file")"
  if [[ -n "$pool_key_tuple" ]]; then
    pool_key_tuple="$(echo "$pool_key_tuple" | tr -d '() ')"
    IFS=',' read -r pool_key_token0 pool_key_token1 _ _ pool_key_hook <<EOF_TUPLE
$pool_key_tuple
EOF_TUPLE
  fi

  token0="${pool_key_token0:-}"
  token1="${pool_key_token1:-}"
  if [[ -z "$token0" || -z "$token1" ]]; then
    token0="$(jq -r '[.transactions[] | select(.contractName == "MockERC20" and .transactionType == "CREATE") | .contractAddress] | .[0] // empty' "$run_file")"
    token1="$(jq -r '[.transactions[] | select(.contractName == "MockERC20" and .transactionType == "CREATE") | .contractAddress] | .[1] // empty' "$run_file")"
  fi
  if [[ -z "$hook_address" && -n "${pool_key_hook:-}" ]]; then
    hook_address="$pool_key_hook"
  fi
  pool_init_tx="$(jq -r '[.transactions[] | select((.function // "") | startswith("initialize(")) | .hash] | .[0] // empty' "$run_file")"
  liquidity_tx="$(jq -r '[.transactions[] | select((.function // "") | startswith("modifyLiquidity(")) | .hash] | .[0] // empty' "$run_file")"
  swap1="$(jq -r '[.transactions[] | select((.function // "") | startswith("swap(")) | .hash] | .[0] // empty' "$run_file")"
  swap2="$(jq -r '[.transactions[] | select((.function // "") | startswith("swap(")) | .hash] | .[1] // empty' "$run_file")"
  swap3="$(jq -r '[.transactions[] | select((.function // "") | startswith("swap(")) | .hash] | .[2] // empty' "$run_file")"
  deployer="$(jq -r '.transactions[0].transaction.from // empty' "$run_file")"

  if [[ "$MODE" == "testnet" ]]; then
    upsert_env_var "${prefix}_DEPLOYER_ADDRESS" "$deployer"
    upsert_env_var "${prefix}_POOL_MANAGER_ADDRESS" "$pool_manager"
    upsert_env_var "${prefix}_SWAP_ROUTER_ADDRESS" "$swap_router"
    upsert_env_var "${prefix}_LIQUIDITY_ROUTER_ADDRESS" "$liquidity_router"
    upsert_env_var "${prefix}_TOKEN0_ADDRESS" "$token0"
    upsert_env_var "${prefix}_TOKEN1_ADDRESS" "$token1"
    upsert_env_var "${prefix}_HOOK_ADDRESS" "$hook_address"

    upsert_env_var "${prefix}_HOOK_DEPLOY_TX" "$hook_tx"
    upsert_env_var "${prefix}_POOL_INIT_TX" "$pool_init_tx"
    upsert_env_var "${prefix}_LIQUIDITY_TX" "$liquidity_tx"
    upsert_env_var "${prefix}_SWAP_TX_1" "$swap1"
    upsert_env_var "${prefix}_SWAP_TX_2" "$swap2"
    upsert_env_var "${prefix}_SWAP_TX_3" "$swap3"

    upsert_env_var "${prefix}_HOOK_DEPLOY_URL" "${EXPLORER_PREFIX}${hook_tx}"
    upsert_env_var "${prefix}_POOL_INIT_URL" "${EXPLORER_PREFIX}${pool_init_tx}"
    upsert_env_var "${prefix}_LIQUIDITY_URL" "${EXPLORER_PREFIX}${liquidity_tx}"
    upsert_env_var "${prefix}_SWAP_URL_1" "${EXPLORER_PREFIX}${swap1}"
    upsert_env_var "${prefix}_SWAP_URL_2" "${EXPLORER_PREFIX}${swap2}"
    upsert_env_var "${prefix}_SWAP_URL_3" "${EXPLORER_PREFIX}${swap3}"
  fi

  echo "[summary][$template] deployer=$deployer poolManager=$pool_manager hook=$hook_address"
  echo "[summary][$template] hookDeployTx=$hook_tx"
}

run_template() {
  local template="$1"
  local script_path
  local script_base
  local run_file
  local template_action
  local pk
  local signer

  script_path="$(script_for_template "$template")"
  if [[ -z "$script_path" ]]; then
    echo "[demo-e2e] ERROR: unsupported template '$template'" >&2
    exit 1
  fi

  script_base="$(basename "$script_path")"
  run_file="$(run_file_for_script "$script_path")"

  case "$ACTION" in
    deploy)
      template_action="deploy"
      ;;
    report)
      template_action="report"
      ;;
    auto)
      if [[ -f "$run_file" ]]; then
        template_action="report"
      else
        template_action="deploy"
      fi
      ;;
  esac

  print_phase_header "$template"
  echo "[workflow][$template] mode=$MODE action=$template_action rpc=$RPC_URL chain=$CHAIN_ID"

  if [[ "$template_action" == "deploy" ]]; then
    pk="$(private_key_for_template "$template")"
    if [[ -z "$pk" ]]; then
      echo "[demo-e2e] ERROR: private key missing for template '$template'" >&2
      exit 1
    fi
    signer="$(cast wallet address --private-key "$pk")"

    echo "[broadcast][$template] signer=$signer"
    echo "[broadcast][$template] running forge script ${script_path}"

    strict_external_manager="false"
    if [[ "$MODE" == "testnet" ]]; then
      strict_external_manager="true"
    fi

    PRIVATE_KEY="$pk" REQUIRE_EXTERNAL_POOL_MANAGER="$strict_external_manager" forge script "$script_path" \
      --rpc-url "$RPC_URL" \
      --private-key "$pk" \
      --broadcast \
      --slow \
      --non-interactive

    run_file="$(run_file_for_script "$script_path")"
  fi

  if [[ ! -f "$run_file" ]]; then
    echo "[demo-e2e] ERROR: broadcast output missing: $run_file" >&2
    exit 1
  fi

  print_tx_report "$template" "$run_file"
  print_event_report "$template" "$run_file"
  persist_metadata "$template" "$run_file"
}

echo "[demo-e2e] mode=$MODE template=$TEMPLATE action=$ACTION"

templates_to_run="$TEMPLATE"
if [[ "$TEMPLATE" == "all" ]]; then
  templates_to_run="stable rwa longtail"
fi

for template in $templates_to_run; do
  run_template "$template"
done

echo ""
echo "[demo-e2e] complete"
if [[ "$MODE" == "testnet" ]]; then
  echo "[demo-e2e] persisted testnet deployment metadata to $ENV_FILE"
fi
