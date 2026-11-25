# devkit

Portable Developer Toolkit: a small, modular CLI for macOS, Ubuntu, and WSL2.

## Quick start

```sh
git clone https://github.com/eic-ks/devkits.git
cd devkits
./install.sh
dev env doctor
```

The installer creates a symlink in `~/.local/bin` (or `DEVKIT_BIN_DIR`) and does not install or update tools. Set `codex_model=MODEL` in `${XDG_CONFIG_HOME:-~/.config}/devkit/config`, or pass a model explicitly. Interactive selection requires `fzf` and model IDs in `config/codex-models.txt`.

## Commands

- `dev env doctor [--json]`: read-only availability check for mise, Git, Python, uv, Docker, SSH, and Codex.
- `dev env info`: show OS, architecture, and paths.
- `dev agent model [MODEL]`: print a configured model or select from the local catalog.
- `dev agent launch [MODEL]`: run `codex -m MODEL`.
- `dev agent doctor`: check Codex CLI and optional `fzf`.
- `dev sandbox doctor`: inspect optional external adapter configuration.

Codex model discovery is intentionally user-configured until the installed CLI's supported discovery interface is verified. Credentials do not belong in this repository.

## Layout

`bin/dev` routes commands to `modules/agent`, `modules/env`, and `modules/sandbox`. Shared configuration helpers live in `modules/lib`. The sandbox module is only an adapter boundary; it does not claim to provide container isolation.

Requires Bash 3.2 or newer. `mise.toml` provides optional `fzf` setup and task aliases. Mise itself is not required to run the CLI.
