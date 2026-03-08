#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

TARGET_PERIPHERY_COMMIT="3779387e5d296f39df543d23524b050f89a62917"

echo "[bootstrap] Syncing git submodules"
git submodule sync --recursive
git submodule update --init --recursive lib/forge-std lib/v4-core lib/v4-periphery

echo "[bootstrap] Pinning v4-periphery -> ${TARGET_PERIPHERY_COMMIT}"
git -C lib/v4-periphery fetch --all --tags --force >/dev/null 2>&1 || true
git -C lib/v4-periphery checkout "$TARGET_PERIPHERY_COMMIT"
git -C lib/v4-periphery submodule update --init --recursive

TARGET_CORE_COMMIT="$(git -C lib/v4-periphery rev-parse HEAD:lib/v4-core)"
echo "[bootstrap] Pinning v4-core -> ${TARGET_CORE_COMMIT} (from v4-periphery submodule pointer)"
git -C lib/v4-core fetch --all --tags --force >/dev/null 2>&1 || true
git -C lib/v4-core checkout "$TARGET_CORE_COMMIT"
git -C lib/v4-core submodule update --init --recursive

ACTUAL_PERIPHERY_COMMIT="$(git -C lib/v4-periphery rev-parse HEAD)"
ACTUAL_CORE_COMMIT="$(git -C lib/v4-core rev-parse HEAD)"

if [[ "$ACTUAL_PERIPHERY_COMMIT" != "$TARGET_PERIPHERY_COMMIT" ]]; then
  echo "[bootstrap] ERROR: v4-periphery mismatch. expected=${TARGET_PERIPHERY_COMMIT} got=${ACTUAL_PERIPHERY_COMMIT}" >&2
  exit 1
fi

if [[ "$ACTUAL_CORE_COMMIT" != "$TARGET_CORE_COMMIT" ]]; then
  echo "[bootstrap] ERROR: v4-core mismatch. expected=${TARGET_CORE_COMMIT} got=${ACTUAL_CORE_COMMIT}" >&2
  exit 1
fi

echo "[bootstrap] OK: deterministic dependency pins are satisfied"
