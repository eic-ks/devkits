# `cx` Codex model selector: research and design

Status: design proposal; implementation is not part of this change.

## 1. Current CLI behavior and verification

Local inspection on 2026-11-25 found `codex-cli 0.172.0` at `/Users/karatsu/.local/bin/codex`.

| Item | Finding | Verification |
| --- | --- | --- |
| `codex -m MODEL` | Supported global option; `--model` is an alias. | `codex --help` |
| `codex debug models` | Present and emits JSON with a top-level `models` array. | `codex debug models --help`; bundled catalog inspection |
| Model ID / label | `slug` is the ID to pass to `-m`; `display_name` is the human label; `description` is available. | Inspected bundled JSON through a field-only summary |
| Visibility | Catalog contains a `visibility` field; this local bundled catalog had 11 `list` and 3 `hide` entries. | Inspected bundled catalog; not compared against `/model` UI |
| API support | `supported_in_api` is a separate boolean field. Do not infer visibility from it alone. | Inspected bundled catalog |
| Resume | `codex resume` accepts `--last` and also exposes `-m, --model`. | `codex resume --help` |
| Resume combination | Help exposes both flags on the same command, so the intended form is `codex resume --last -m MODEL`. The actual continuation effect was not exercised against a real saved session. | CLI parser help only |
| `/model` relationship | Official user documentation says `/model` chooses the model and reasoning effort for the current session. Exact parity between its picker and `debug models` was not verified. | [Codex CLI documentation](https://developers.openai.com/codex/cli/) |

The official command reference labels `codex debug models` **Experimental**, describes it as the raw model catalog Codex sees, and documents `--bundled` as skipping remote refresh. It is therefore useful for an adapter with version checks, but is not a stable public API contract. See [Developer commands reference](https://developers.openai.com/codex/developer-commands?surface=cli#codex-debug-models) and the [open-source CLI argument definition](https://github.com/openai/codex/blob/main/codex-rs/cli/src/main.rs).

The default `codex debug models` command was not run: it may refresh the remote catalog and touch Codex-managed cache state outside this workspace. Thus live network behavior, refresh latency/failure codes, account filtering, and config/cache side effects remain unverified here. `--bundled` was run and produced 14 models. The full JSON was not printed; fields such as `base_instructions` and `model_messages` mean the raw output should be treated as potentially sensitive diagnostic data.

The CLI help confirms `-m` but does not by itself prove all configuration precedence or persistence details. Expected behavior is that the explicit invocation flag overrides the configured default for that launch. Do not claim that `/model` never writes settings: its documented effect is on the current session, and persistent side effects need a before/after config check in a controlled TUI session.

## 2. Discovery options and reliability

| Source | Advantages | Limitations | Recommendation |
| --- | --- | --- | --- |
| `codex debug models` | Dynamic catalog Codex itself reads; gives ID, display label, description, visibility, capabilities | Officially Experimental; remote refresh and failure semantics can change; raw JSON includes non-display internal content | Primary adapter for now, behind schema validation and version-aware errors |
| `codex debug models --bundled` | No network; supported by local CLI help; a deterministic fallback | Stale relative to remote/account catalog; may include hidden models and omit new ones | Use only as explicit offline fallback, and label it bundled/stale |
| `~/.codex/models_cache.json` | May reflect a prior refresh | Internal file, schema and lifecycle are not a supported interface | Do not read it |
| Direct models endpoint / undocumented API | Could be dynamic | Authentication and response contract are not public/stable for this use | Do not implement |
| Hand-maintained model list | Works offline and is easy to understand | Goes stale; conflicts with desired dynamic list | Last-resort user override, never ship a baked-in list as authoritative |

The visible selection should initially include entries with `visibility == "list"`, use `slug` as the command ID, and display `display_name` plus optional `description`. That is an evidence-based heuristic, not yet proven to exactly match `/model`; compare both lists on the target account before treating it as parity. Filter output to these allowlisted fields before it reaches the UI or `cx models --json` so instruction-bearing fields never escape the parser.

Do not add a separate persistent cache in the MVP. On successful dynamic discovery, use the returned list immediately. On failure, offer bundled fallback only when the user explicitly enables it (for example `--fallback bundled`) or make that choice explicit in the selector; never silently present stale models as current. If a future cache is needed, store only sanitized fields under `${XDG_CACHE_HOME:-~/.cache}/cx/`, with source, CLI version, fetched time, and a short TTL. No authentication data belongs there.

## 3. Implementation choice

**Recommend Bash + jq + fzf**, with mise optional for repeatable dependency setup.

| Option | Trade-off | Decision |
| --- | --- | --- |
| Bash + jq + fzf | Low startup cost; excellent shell argument transparency; each dependency has a narrow role; jq provides strict JSON parsing | Best fit for a small launcher. Require Codex, jq, and fzf for dynamic interactive selection; use mise as a convenience, not runtime |
| Python | Strong JSON handling and test ergonomics | Extra interpreter/runtime packaging for a process wrapper; reconsider only if logic grows beyond a thin adapter |
| Rust | Distributable single binary and strong types | Build/release matrix and TUI cost are too high for the initial narrow use case |
| mise task | Convenient tool pinning and task aliases | Does not provide the UX by itself and couples a personal shortcut to mise; keep logic in `cx`, let mise provision jq/fzf optionally |

The app is the executable shell script; `mise.toml` may pin jq/fzf versions and provide install/doctor tasks, but `cx` must work without mise when dependencies are already installed.

## 4. Proposed CLI contract

```text
cx [CODEX-ARGS...]
cx resume [--last | SESSION_ID] [CODEX-ARGS...]
cx models [--json] [--bundled]
cx doctor
```

- Bare `cx` discovers models, presents fzf, then `exec`s Codex with `-m ID` and all caller arguments.
- `cx --help`, `cx -h`, and `cx --version` bypass the picker and pass straight to Codex.
- If caller args contain `-m ID`, `--model ID`, or `--model=ID`, bypass discovery and pass the full original argument vector unchanged. The caller's explicit model wins; duplicate model flags are left to Codex to diagnose rather than guessed at by the wrapper.
- `cx resume ...` selects a model and launches `codex resume ... -m ID` (or an equivalent parser-verified arrangement). Explicit model flags again bypass selection.
- A selected model is a per-process launch argument. The wrapper never edits `config.toml`, shell rc files, or Codex cache files.
- Preserve current working directory. Do not convert arguments to a shell command string; use arrays and `exec codex ... "$@"`.
- `cx models` prints safe, sanitized fields. `cx models --json` emits a documented object such as `{"source":"remote","models":[{"id":"...","name":"...","description":"..."}]}`. It is the wrapper's stable output contract, independent of Codex's raw JSON schema.
- `cx models --bundled` invokes `codex debug models --bundled` and returns source `bundled`; normal `cx models` uses dynamic discovery.

Interactive selection should use fzf defaults: arrow keys, incremental query, Enter selection, Escape/Ctrl-C cancellation. If canceled, exit with a cancellation status and never start Codex. The selected label is for humans only; only the `slug`/ID is passed to `-m`.

## 5. Suggested module layout

```text
bin/cx                         standalone executable
modules/codex/models.sh        discovery, filtering, source/fallback
modules/codex/select.sh        fzf input and selected ID
modules/codex/launch.sh        argument classification and exec
lib/json.sh                    jq schema validation / safe projection
tests/fixtures/models-valid.json
tests/fixtures/models-unexpected.json
tests/mocks/codex
tests/mocks/fzf
mise.toml                      optional jq/fzf version and tasks
```

To integrate with devkit, `bin/dev agent model` should call the same discovery/selection function (or `cx models` / a machine interface) rather than maintaining a second model catalog. `cx` remains the standalone user-facing shortcut.

## 6. Errors and fallbacks

| Condition | Behavior |
| --- | --- |
| `codex` absent | Clear diagnostic, exit 127 |
| `jq` or `fzf` absent for interactive mode | Name missing dependency and show install guidance; do not invoke Codex with an implicit model |
| discovery command unsupported / JSON invalid / required fields missing | Explain incompatible Codex CLI/catalog; nonzero exit; allow explicit bundled fallback |
| remote discovery failure or empty visible list | Distinguish failure from valid empty result; do not silently select a hidden/default model |
| Escape/Ctrl-C | Nonzero cancellation exit; no Codex child process |
| unknown JSON fields | Ignore them; do not fail just because upstream adds optional metadata |
| invalid/non-string ID or display label | Drop malformed entry; if no valid entries remain, report schema error |
| Codex exit | `exec` preserves its exit code and signal behavior |

Never log raw model JSON, command environment, or tokens. Validate IDs as non-empty strings and pass them as a single argv element; no `eval` or shell interpolation.

## 7. Test plan

Tests use temporary mock executables placed first on `PATH`; no real Codex session or network call is needed for unit coverage.

1. Project valid model JSON to `id`, `name`, `description` only; ensure internal fields are absent.
2. Parse missing `models`, wrong types, empty list, hidden entries, and unknown extra fields.
3. Verify label and ID stay paired even with spaces, quotes, or Unicode in labels.
4. fzf mock returns selected ID; cancellation returns nonzero and leaves the codex mock log empty.
5. Codex mock records argv boundaries and current directory for regular launch, `--cd` with a space, sandbox flags, prompt arguments, and `resume --last`.
6. Explicit `-m`, `--model`, and `--model=...` bypass the picker and preserve args exactly.
7. `--help` / `--version` bypass model lookup.
8. Mock Codex exits with a chosen status; wrapper returns the same status.
9. Hash `~/.codex/config.toml` (or a temporary `CODEX_HOME`) before and after a mocked launch and assert unchanged. A separate manual acceptance check should run an actual TUI launch and inspect config before/after; this is needed to validate end-to-end behavior, not the mocked argument builder.
10. Run shell syntax checks and the same fixture suite on macOS and Ubuntu/WSL2; verify Bash 3.2-compatible syntax if supporting Apple's system Bash.

## 8. MVP implementation order

1. Keep the current skeleton's Codex adapter boundary, but replace its hand-maintained-only model list with a dedicated `codex debug models` parser.
2. Add strict jq allowlist projection and catalog validation; document the Experimental dependency.
3. Implement fzf selection with cancel semantics and an explicit bundled fallback.
4. Implement argument routing, help/version bypass, explicit `-m` bypass, resume routing, and `exec` pass-through.
5. Add `models`, `models --json`, and `doctor` commands with stable output and actionable dependency checks.
6. Add mocked tests for argument safety, filtering, cancellation, exit status, CWD, and config non-mutation.
7. Validate on macOS and Ubuntu, compare `cx models` to the interactive `/model` list, and manually verify selected model and config behavior in a real session.
8. Add optional mise setup and a clone/symlink installation note; keep the script runnable directly from a Git checkout and updateable with `git pull`.

### Open verification gates before calling MVP complete

- Does dynamic `codex debug models` use account-visible state on the installed CLI, and does its `visibility == "list"` subset match `/model`?
- What nonzero status and stderr behavior occur offline or when the refresh fails?
- Does launching with `-m` leave the default config unchanged, and does the chosen model apply only to that new session?
- Does model override behave as expected when resuming an older session with a different reasoning-effort setting?
