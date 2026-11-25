# Repository guidance

- Keep this repository's working context in the code and current user documentation. Do not add progress journals, meeting notes, change diaries, decision archives, or completed plans.
- Keep `README.md` in English. Write code comments and internal documentation in Japanese. Keep CLI help, diagnostics, errors, installer output, and other user-facing messages in English.
- Prefer the implementation as the source of truth. Document behavior only when a user or contributor needs information that cannot be read directly from the code.
- Keep design documents only for unfinished work. When a design is implemented, move any still-needed acceptance criteria into code or tests, update the relevant current documentation, then delete the design document. Do not preserve it as an archive.
- Delete obsolete or duplicate prose in the same change that makes it obsolete. Do not create a replacement archive or changelog entry for removed context.
- Do not copy source comments or implementation inventories into documentation. Keep instructions here short and project-wide.
- `bin/dev` is the command entry point; feature code belongs in focused modules. Keep sandbox-specific container behavior behind `modules/sandbox` and do not imply security guarantees that have not been verified.
- Do not add credentials, machine-specific paths, or generated Codex catalogs to the repository.
