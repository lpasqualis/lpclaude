# Authoring reference (not compiled into global directives)

`rebuild_claude_md.sh` globs `directives/*.md` only — it does **not** recurse into
subdirectories. Files here are therefore **excluded** from `CLAUDE_global_directives.md`
and are not loaded into every session.

This is intentional. The content here is only relevant when *authoring* Claude Code
components (slash commands, subagents, workers) or building AI tooling — work that
happens in this repo, not in every project. Keeping it out of the always-on global
directives saves context everywhere it isn't needed.

The repo's project `CLAUDE.md` points here so this guidance is discoverable when
working in this repo.

Contents:
- `component_authoring.md` — choosing/wiring slash commands, subagents, workers; execution hierarchy and constraints.
- `prompt_engineering.md` — prompt-engineering best practices for writing instructions for an AI.
- `ai_code_synergy.md` — the AI-provides-intelligence / code-provides-reliability design pattern.
