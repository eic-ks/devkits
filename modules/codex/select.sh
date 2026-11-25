#!/usr/bin/env bash

cx_select_model() {
  local source="${1:-codex}" catalog rows selected status
  command -v jq >/dev/null 2>&1 || { printf 'cx: error: jq is required\n' >&2; return 127; }
  command -v fzf >/dev/null 2>&1 || { printf 'cx: error: fzf is required for interactive model selection\n' >&2; return 127; }
  catalog="$(cx_model_catalog "$source")" || return $?
  if [[ "$(printf '%s\n' "$catalog" | jq '.models | length')" -eq 0 ]]; then
    printf 'cx: error: no visible models were returned\n' >&2
    return 1
  fi
  rows="$(printf '%s\n' "$catalog" | jq -r '.models[] | [.id, .name, .description] | @tsv')"
  if selected="$(printf '%s\n' "$rows" | fzf --delimiter=$'\t' --with-nth='2..' --prompt='Codex model> ')"; then
    printf '%s\n' "${selected%%$'\t'*}"
  else
    status=$?
    return "$status"
  fi
}
