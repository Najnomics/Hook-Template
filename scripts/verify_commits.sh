#!/usr/bin/env bash
set -euo pipefail

EXPECTED_COUNT=300
EXPECTED_AUTHOR="najnomics <jesuorobonosakhare873@gmail.com>"

COUNT="$(git rev-list --count HEAD)"
if [[ "$COUNT" -ne "$EXPECTED_COUNT" ]]; then
  echo "[verify-commits] ERROR: expected ${EXPECTED_COUNT} commits, found ${COUNT}" >&2
  exit 1
fi

NON_MATCHING="$(git log --format='%an <%ae>' | rg -v "^${EXPECTED_AUTHOR}$" || true)"
if [[ -n "$NON_MATCHING" ]]; then
  echo "[verify-commits] ERROR: found commits with different author identity" >&2
  echo "$NON_MATCHING" >&2
  exit 1
fi

echo "[verify-commits] OK: commit count and author identity verified"
