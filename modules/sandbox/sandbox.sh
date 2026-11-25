#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/modules/lib/common.sh"
[[ "${1:-}" == doctor ]] || { devkit_error 'sandboxの操作が不明です'; exit 2; }
adapter="$(devkit_config_value sandbox_adapter || true)"
if [[ -z "$adapter" ]]; then
  printf 'sandboxアダプター: 未設定\n想定インターフェース: adapter doctor | run <profile> -- <command...>\n'
elif ! command -v "$adapter" >/dev/null 2>&1; then
  devkit_error "設定されたアダプターが見つかりません: $adapter"; exit 1
else
  printf 'sandboxアダプター: %s\n' "$(command -v "$adapter")"
fi
