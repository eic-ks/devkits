#!/usr/bin/env bash

cx_has_model_option() {
  local arg
  for arg in "$@"; do
    case "$arg" in
      --) break ;;
      -m|--model) return 0 ;;
      --model=*) return 0 ;;
    esac
  done
  return 1
}

cx_has_direct_option() {
  local arg
  for arg in "$@"; do
    case "$arg" in -h|--help|-V|--version) return 0 ;; esac
  done
  return 1
}

cx_launch() {
  local source="${1:-codex}" model status
  shift || true
  command -v codex >/dev/null 2>&1 || { printf 'cx: error: codex CLI not found\n' >&2; return 127; }

  if cx_has_direct_option "$@" || cx_has_model_option "$@"; then
    exec codex "$@"
  fi
  command -v jq >/dev/null 2>&1 || { printf 'cx: error: jq is required\n' >&2; return 127; }
  command -v fzf >/dev/null 2>&1 || { printf 'cx: error: fzf is required for interactive model selection\n' >&2; return 127; }
  if model="$(cx_select_model "$source")"; then
    if [[ "${1:-}" == resume ]]; then
      shift
      exec codex resume "$@" -m "$model"
    fi
    exec codex -m "$model" "$@"
  else
    status=$?
    return "$status"
  fi
}
