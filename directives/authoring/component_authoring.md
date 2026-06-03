# Authoring Claude Code Components

Reference for writing slash commands, subagents, and workers in this repo and others.
Consolidated from the non-obvious, easy-to-get-wrong details; basic definitions
(what a slash command/subagent *is*) are intentionally omitted because the model
already knows them.

## Choosing the execution method

- **Slash command** — user-triggered reusable prompt, AND any of: orchestrates
  multiple operations, needs specific tool restrictions, or needs full conversation
  context.
- **Subagent** — specialized expertise needed, AND any of: auto-trigger on keywords,
  or Main Claude should invoke it programmatically.
- **Worker** — only ever called by slash commands, AND any of: needs parallel
  execution, or is shared across multiple commands. (Worker = a pure-prompt template
  in `workers/`; this is a local convention, not a built-in Claude Code concept.)
- **Inline prompt** — called by a slash command, and neither needs parallel execution
  nor is shared across commands. Just write it inline.

## Execution hierarchy

```
Main Claude      → can invoke: subagents, slash commands, Task tool
Slash commands   → can invoke: subagents + workers via Task tool, other slash commands via SlashCommand tool
Subagents/Workers→ CANNOT use Task tool (no subagents/workers), but CAN run slash commands via SlashCommand
```

## Key constraints (frequently gotten wrong)

- **Task tool**: max 10 concurrent invocations.
- **No recursive delegation**: anything invoked via Task cannot itself use Task.
- **Subagents/workers run in fresh, separate context** — they don't see the main
  conversation.
- **Auto-trigger only on user input**: a subagent's keyword description triggers from
  the user's messages, never from Claude's own output. Claude can still invoke a
  subagent explicitly.
- **No `proactive` YAML field** — express it with "MUST BE USED PROACTIVELY" in the
  `description`.
- **Subagents must not list Task in `tools`** — it's filtered at the framework level.
- **Agent and slash-command changes require a Claude Code restart** — they load at
  startup only.

## Slash command gotchas

- **Code blocks are inert text.** Claude sees any fenced block in a slash command as
  plain text; it does nothing with it unless the command *explicitly* instructs it to.
- **`$ARGUMENTS`** is expanded before Claude sees the prompt (`/cmd foo bar` →
  `$ARGUMENTS` becomes `foo bar`).
- **`!` bash pre-execution** runs *before* Claude sees the prompt and its stdout is
  spliced in. Limits: each `!` runs in isolation (no variable persistence between
  them), it only sees existing env vars, and the output is static text. Markdown bash
  blocks are NOT auto-executed — only the `!` prefix is.
- **`@file` references** expand to the file's contents before Claude sees them, and
  Claude also receives any `CLAUDE.md` in that file's directory. Read at execution
  time (fresh). Directory refs show a listing, not contents. Large files are included
  in full — mind the context budget.
- **Context cost / opt-out**: slash-command metadata (name, args, description) is
  loaded into context via the SlashCommand tool. Add `disable-model-invocation: true`
  to the frontmatter to exclude a command from that tool and save context.

## File locations

| Component      | Project (`.claude/`) | Global (`~/.claude/`) |
|----------------|----------------------|------------------------|
| Slash commands | `.claude/commands`   | `~/.claude/commands`   |
| Subagents      | `.claude/agents`     | `~/.claude/agents`     |
| Workers        | `workers/`           | `~/.claude/workers`    |

Project components take precedence over global ones with the same name.
