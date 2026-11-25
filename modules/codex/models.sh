#!/usr/bin/env bash

# Codexのrawカタログから、表示に必要な項目だけを抽出する。
cx_model_catalog() {
  local source="${1:-codex}" raw catalog
  if ! command -v codex >/dev/null 2>&1; then
    printf 'cx: error: codex CLI not found\n' >&2
    return 127
  fi

  if [[ "$source" == bundled ]]; then
    if ! raw="$(codex debug models --bundled 2>/dev/null)"; then
      printf 'cx: error: failed to read the bundled model catalog\n' >&2
      return 1
    fi
  else
    if ! raw="$(codex debug models 2>/dev/null)"; then
      printf 'cx: error: model discovery failed; check your Codex CLI and network, or retry with --bundled\n' >&2
      return 1
    fi
  fi

  if ! catalog="$(printf '%s\n' "$raw" | jq -ce '
    if (.models | type) != "array" then error("missing models array") else
      {models: [
        .models[]
        | select(type == "object")
        | select(.visibility == "list")
        | select((.slug | type) == "string" and (.slug | length) > 0)
        | select((.display_name | type) == "string" and (.display_name | length) > 0)
        | {id: .slug, name: .display_name,
           description: (if (.description | type) == "string" then .description else "" end)}
      ]}
    end
  ' 2>/dev/null)"; then
    printf 'cx: error: Codex returned an invalid model catalog\n' >&2
    return 1
  fi
  printf '%s\n' "$catalog"
}

cx_models_command() {
  local source="${1:-codex}" format="${2:-text}" catalog
  catalog="$(cx_model_catalog "$source")" || return $?
  if [[ "$format" == json ]]; then
    printf '%s\n' "$catalog" | jq --arg source "$source" '{source: $source, models: .models}'
    return
  fi
  if [[ "$(printf '%s\n' "$catalog" | jq '.models | length')" -eq 0 ]]; then
    printf 'cx: no visible models were returned\n' >&2
    return 1
  fi
  printf '%-24s %-28s %s\n' MODEL ID DESCRIPTION
  printf '%s\n' "$catalog" | jq -r '.models[] | [.name, .id, .description] | @tsv' |
    while IFS="$(printf '\t')" read -r name id description; do
      printf '%-24s %-28s %s\n' "$name" "$id" "$description"
    done
}
