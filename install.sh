#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEST="${DEVKIT_BIN_DIR:-$HOME/.local/bin}"
mkdir -p "$DEST"
ln -sfn "$ROOT/bin/dev" "$DEST/dev"
chmod +x "$ROOT/bin/dev" "$ROOT/modules/agent/agent.sh" "$ROOT/modules/env/env.sh" "$ROOT/modules/sandbox/sandbox.sh"
printf 'Installed dev to %s/dev\nEnsure %s is on PATH.\n' "$DEST" "$DEST"
