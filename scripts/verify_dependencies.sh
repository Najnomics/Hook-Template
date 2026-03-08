#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

bash scripts/bootstrap.sh

if [[ ! -f package-lock.json ]]; then
  echo "[verify] ERROR: package-lock.json is missing" >&2
  exit 1
fi

echo "[verify] Running deterministic Node install check"
npm ci --ignore-scripts >/dev/null

echo "[verify] Running Foundry build integrity check"
forge build >/dev/null

echo "[verify] Dependency integrity checks passed"
