#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/modules/lib/common.sh"
[[ "${1:-}" == doctor ]] || { devkit_error 'unknown sandbox operation'; exit 2; }
adapter="$(devkit_config_value sandbox_adapter || true)"
if [[ -z "$adapter" ]]; then
  printf 'sandbox adapter: not configured\nExpected interface: adapter doctor | run <profile> -- <command...>\n'
elif ! command -v "$adapter" >/dev/null 2>&1; then
  devkit_error "configured adapter not found: $adapter"; exit 1
else
  printf 'sandbox adapter: %s\n' "$(command -v "$adapter")"
fi
