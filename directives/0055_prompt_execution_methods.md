# Prompt Execution Methods

## Quick Decision Guide

Choose your execution method based on these criteria:

### Use SLASH COMMAND when:
- User-triggered REUSABLE prompt
- AND ANY of:
  - orchestrates multiple operations
  - requires specific tool restrictions
  - requires full context

### Use SUBAGENT when:
- Specialized expertise required
- AND ANY of:
  - Auto-trigger on keywords needed
  - Main Claude should invoke it programmatically

### Use WORKER when:
- Only called by slash commands
- AND ANY of:
  - Needs parallel execution
  - Shared across multiple commands

### Use INLINE PROMPT when:
- Called by slash commands
- AND NEITHER:
  - Needs parallel execution
  - Shared across multiple commands

## Execution Hierarchy

```
Main Claude → Can invoke: subagents, slash commands, Task tool
Slash Commands → Can invoke: subagents, workers via Task tool, other slash commands via SlashCommand tool
Subagents/Workers → Cannot invoke: other subagents/workers (no Task tool), but CAN execute slash commands via SlashCommand tool (even if they invoke Tasks or subagents)
```

## Key Constraints

- **Task tool limit**: Max 10 concurrent invocations
- **No recursive delegation**: Prompts invoked via Task cannot use Task tool
- **Fresh context**: Subagents/workers run with separate fresh context
- **Auto-trigger**: Keywords only trigger subagents from user input, not Claude output (but Claude can explicitly invoke subagents)

 ## File Locations
  | Component | Project | Global |
  |-----------|---------|--------|
  | Slash commands | `.claude/commands` | `~/.claude/commands` |
  | Subagents | `.claude/agents` | `~/.claude/agents` |
  | Workers | `workers/` | `~/.claude/workers` |