#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/modules/lib/common.sh"
tools=(mise git python3 uv docker ssh codex)
case "${1:-}" in
  doctor)
    if [[ "${2:-}" == --json ]]; then
      printf '{"tools":['; sep=''
      for tool in "${tools[@]}"; do
        if path="$(command -v "$tool" 2>/dev/null)"; then found=true; else found=false; path=''; fi
        printf '%s{"name":"%s","available":%s,"path":"%s"}' "$sep" "$tool" "$found" "$path"; sep=','
      done
      printf ']}\n'
    else
      printf '%-10s %-10s %s\n' TOOL STATUS PATH
      for tool in "${tools[@]}"; do if path="$(command -v "$tool" 2>/dev/null)"; then printf '%-10s %-10s %s\n' "$tool" available "$path"; else printf '%-10s %-10s -\n' "$tool" missing; fi; done
    fi
    ;;
  info) printf 'os: %s\narch: %s\ndevkit: %s\nconfig: %s\n' "$(uname -s)" "$(uname -m)" "$ROOT" "$(devkit_config_dir)" ;;
  *) devkit_error 'unknown env operation'; exit 2 ;;
esac
