#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/modules/lib/common.sh"
source "$ROOT/modules/codex/models.sh"
source "$ROOT/modules/codex/select.sh"
source "$ROOT/modules/codex/launch.sh"
case "${1:-}" in
  model)
    if [[ -n "${2:-}" ]]; then printf '%s\n' "$2"; else cx_select_model codex; fi
    ;;
  launch) shift; shift; exec "$ROOT/bin/cx" "$@" ;;
  doctor) exec "$ROOT/bin/cx" doctor ;;
  *) devkit_error 'unknown agent operation'; exit 2 ;;
esac
