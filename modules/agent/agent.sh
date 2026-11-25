#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/modules/lib/common.sh"
configured_model() { devkit_config_value codex_model || true; }
select_model() {
  local requested="${1:-}" configured="$(configured_model)" catalog="$ROOT/config/codex-models.txt"
  [[ -n "$requested" ]] && { printf '%s\n' "$requested"; return; }
  [[ -n "$configured" ]] && { printf '%s\n' "$configured"; return; }
  if command -v fzf >/dev/null 2>&1 && [[ -s "$catalog" ]]; then
    model="$(awk 'NF && $0 !~ /^[[:space:]]*#/ { print }' "$catalog" | fzf --prompt='Codex model> ')"
    [[ -n "$model" ]] || return 1
    printf '%s\n' "$model"
    return
  fi
  devkit_error 'Pass a model, configure codex_model, or install fzf and populate the model catalog.'; return 1
}
case "${1:-}" in
  model) select_model "${2:-}" ;;
  launch) command -v codex >/dev/null 2>&1 || { devkit_error 'codex CLI not found'; exit 127; }; model="$(select_model "${2:-}")"; exec codex -m "$model" ;;
  doctor)
    if command -v codex >/dev/null 2>&1; then printf 'codex\tavailable\t%s\n' "$(command -v codex)"; else printf 'codex\tmissing\tInstall Codex CLI\n'; fi
    if command -v fzf >/dev/null 2>&1; then printf 'fzf\tavailable\t%s\n' "$(command -v fzf)"; else printf 'fzf\toptional\tInstall fzf for interactive selection\n'; fi
    ;;
  *) devkit_error 'unknown agent operation'; exit 2 ;;
esac
