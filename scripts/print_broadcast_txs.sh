#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 3 ]]; then
  echo "usage: $0 <script-file> <chain-id> <explorer-prefix>" >&2
  exit 1
fi

SCRIPT_FILE="$1"
CHAIN_ID="$2"
EXPLORER_PREFIX="$3"

RUN_FILE="broadcast/${SCRIPT_FILE}/${CHAIN_ID}/run-latest.json"
if [[ ! -f "$RUN_FILE" ]]; then
  ALT_RUN_FILE="broadcast/$(basename "$SCRIPT_FILE")/${CHAIN_ID}/run-latest.json"
  if [[ -f "$ALT_RUN_FILE" ]]; then
    RUN_FILE="$ALT_RUN_FILE"
  else
    echo "[demo] WARNING: broadcast output not found at ${RUN_FILE}" >&2
    exit 0
  fi
fi

HASHES="$(jq -r '.transactions[]? | (.hash // .transactionHash // .txHash // empty)' "$RUN_FILE")"
if [[ -z "$HASHES" ]]; then
  echo "[demo] No transactions in ${RUN_FILE}"
  exit 0
fi

while IFS= read -r HASH; do
  [[ -z "$HASH" ]] && continue
  echo "[demo] tx: ${HASH}"
  echo "[demo] explorer: ${EXPLORER_PREFIX}${HASH}"
done <<< "$HASHES"
