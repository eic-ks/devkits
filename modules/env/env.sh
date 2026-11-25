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
      printf '%-10s %-10s %s\n' ツール 状態 パス
      for tool in "${tools[@]}"; do if path="$(command -v "$tool" 2>/dev/null)"; then printf '%-10s %-10s %s\n' "$tool" 利用可能 "$path"; else printf '%-10s %-10s -\n' "$tool" 未導入; fi; done
    fi
    ;;
  info) printf 'OS: %s\nCPUアーキテクチャ: %s\ndevkitの場所: %s\n設定ファイルの場所: %s\n' "$(uname -s)" "$(uname -m)" "$ROOT" "$(devkit_config_dir)" ;;
  *) devkit_error 'envの操作が不明です'; exit 2 ;;
esac
