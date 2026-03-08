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
  echo "[demo] WARNING: broadcast output not found at ${RUN_FILE}" >&2
  exit 0
fi

node - "$RUN_FILE" "$EXPLORER_PREFIX" <<'NODE'
const fs = require("fs");
const file = process.argv[2];
const explorer = process.argv[3];
const json = JSON.parse(fs.readFileSync(file, "utf8"));
const txs = Array.isArray(json.transactions) ? json.transactions : [];
if (txs.length === 0) {
  console.log(`[demo] No transactions in ${file}`);
  process.exit(0);
}
for (const tx of txs) {
  const hash = tx.hash || tx.transactionHash || tx.txHash;
  if (!hash) continue;
  console.log(`[demo] tx: ${hash}`);
  console.log(`[demo] explorer: ${explorer}${hash}`);
}
NODE
