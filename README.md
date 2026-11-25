# devkit

Portable Developer Toolkit: a small, modular CLI for macOS, Ubuntu, and WSL2.

## Quick start

```sh
git clone https://github.com/eic-ks/devkits.git
cd devkits
./install.sh
dev env doctor
```

The installer creates `dev` and `cx` symlinks in `~/.local/bin` (or `DEVKIT_BIN_DIR`) and does not install or update tools. The Codex model selector requires Codex CLI, `jq`, and `fzf`; use `mise install` to provision the optional dependencies listed in `mise.toml`.

## Commands

- `dev env doctor [--json]`: read-only availability check for mise, Git, Python, uv, Docker, SSH, and Codex.
- `dev env info`: show OS, architecture, and paths.
- `dev agent model [MODEL]`: print a model ID or interactively select one.
- `dev agent launch [CODEX-ARGS...]`: choose a model and launch Codex, or pass an explicit `-m/--model` through.
- `dev agent doctor`: check Codex CLI and optional `fzf`.
- `dev sandbox doctor`: inspect optional external adapter configuration.
- `cx [CODEX-ARGS...]`: choose a model and launch Codex directly.
- `cx resume [--last | SESSION_ID]`: choose a model and resume a Codex session.
- `cx models [--json] [--bundled]`: list visible models, optionally as sanitized JSON or from the bundled catalog.
- `cx doctor`: check the model selector dependencies and catalog command.

`cx` reads the catalog from `codex debug models`, an Experimental Codex CLI command. Use `cx --bundled` or `cx models --bundled` to explicitly use the catalog shipped with the installed Codex CLI. Credentials do not belong in this repository.

## Layout

`bin/dev` and `bin/cx` are command entry points. Codex model discovery, selection, and launch live in `modules/codex` and are shared with `dev agent`. Other feature code lives in `modules/agent`, `modules/env`, and `modules/sandbox`. Shared configuration helpers live in `modules/lib`. The sandbox module is only an adapter boundary; it does not claim to provide container isolation.

Requires Bash 3.2 or newer. `mise.toml` provides optional `fzf` setup and task aliases. Mise itself is not required to run the CLI.
