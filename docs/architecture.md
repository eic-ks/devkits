# Architecture and integration decision

## Evidence status

`PLAN.md` reports `eic-ks/ai_template_docker` as a Python 3.12/uv Dev Container template with Dockerfile, devcontainer settings, and sample project files. A direct live GitHub fetch failed in this environment (cache miss), so this is inherited information, not fresh verification. Confirm its current `master` tree, license, history, and runtime behavior before adopting or moving files.

## Responsibility boundary

`dev` owns portable command routing, user-level configuration, agent selection and launch, and read-only diagnostics. A sandbox implementation owns image/container construction, isolation, mounts, credential handoff, and network policy. Docker-specific flags do not belong in agent or env modules.

Provisional adapter contract:

```text
<adapter> doctor [--json]
<adapter> run <profile> -- <command> [args...]
<adapter> stop <session-id>
```

The scaffold currently checks only that a configured adapter executable exists. This proposal is not validated against `ai_template_docker`.

## Integration options

| Option | Advantages | Costs / risks | Current fit |
| --- | --- | --- | --- |
| Keep independent | Preserves release cadence, history, and standalone use | Coordinate two repos and versions | Best while responsibilities are uncertain |
| External CLI adapter | Clear boundary; no copied source; can pin a release/revision | Requires stable CLI and compatibility policy | Preferred first integration |
| Git subtree | Source and history can live in one repo; upstream can remain standalone | Sync workflow and imported history need ownership | Revisit if code-level integration is frequent |
| History-preserving monorepo import | One release and tests; natural module ownership | Migration and upstream divergence burden | Consider after requirements mature |
| Git submodule | Explicit upstream commit pin | More complex clone/update experience | Not for MVP |

Keep `ai_template_docker` independent for now. Based on the plan's description, it is a development template, not a hardened agent sandbox; do not claim security properties it has not demonstrated. Its Python/Kaggle image could later become an `ai-research` profile. An agent sandbox needs separate threat modeling and validation.

## MVP sequence

1. Establish `dev` routing and a GitHub clone/symlink installer.
2. Add read-only diagnostics for mise, Git, Python, uv, Docker, SSH, and Codex, with JSON output.
3. Launch Codex through `codex -m MODEL`. Keep model discovery explicit/configured until the supported interface is verified. Interactive fzf selection reads an optional local catalog.
4. Define the sandbox adapter interface; add no container lifecycle until the external repository and security requirements are reviewed.

## Migration path

Keep the adapter contract stable while the implementation moves from an external executable to `modules/sandbox/adapters/<name>`. Pin external adapters by immutable release or commit. Preserve upstream license and history if source is imported. A single `sandbox_adapter` config key selects the executable; avoid a plugin registry until there is more than one real adapter.
