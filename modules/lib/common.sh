#!/usr/bin/env bash
devkit_config_dir() { printf '%s\n' "${XDG_CONFIG_HOME:-$HOME/.config}/devkit"; }
devkit_config_value() {
  local key="$1" file
  file="$(devkit_config_dir)/config"
  [[ -f "$file" ]] || return 1
  awk -F= -v key="$key" '$1 == key { sub(/^[^=]*=/, ""); print; exit }' "$file"
}
devkit_error() { printf 'dev: エラー: %s\n' "$*" >&2; }
