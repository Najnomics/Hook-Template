#!/usr/bin/env bash
set -euo pipefail

THRESHOLD="${COVERAGE_THRESHOLD:-100}"
TMP_FILE="$(mktemp)"
trap 'rm -f "$TMP_FILE"' EXIT

# Foundry may panic on some macOS setups when online signature lookup is enabled.
# Default to offline mode for deterministic CI/local coverage unless explicitly overridden.
FOUNDRY_OFFLINE="${FOUNDRY_OFFLINE:-true}" \
  forge coverage --report summary --exclude-tests --no-match-coverage 'script/' > "$TMP_FILE"
TOTAL_LINE="$(rg '^\| Total\s+' "$TMP_FILE" || true)"
if [[ -z "$TOTAL_LINE" ]]; then
  echo "[coverage-gate] ERROR: could not parse coverage summary" >&2
  cat "$TMP_FILE" >&2
  exit 1
fi

LINES_PCT="$(echo "$TOTAL_LINE" | sed -E 's/.*\| ([0-9]+\.[0-9]+)% \(.*/\1/' | head -n1)"
if [[ -z "$LINES_PCT" ]]; then
  echo "[coverage-gate] ERROR: could not parse line coverage percentage" >&2
  cat "$TMP_FILE" >&2
  exit 1
fi

awk -v value="$LINES_PCT" -v threshold="$THRESHOLD" 'BEGIN { exit (value + 0 >= threshold + 0 ? 0 : 1) }'
if [[ $? -ne 0 ]]; then
  echo "[coverage-gate] ERROR: line coverage ${LINES_PCT}% < threshold ${THRESHOLD}%" >&2
  exit 1
fi

echo "[coverage-gate] OK: line coverage ${LINES_PCT}% >= threshold ${THRESHOLD}%"
