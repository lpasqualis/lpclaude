# Migration Guide: From cmd-* Subagents to Task Templates

## Executive Summary

This guide documents the migration from cmd-* subagents to a task template pattern for the Claude Framework Development Workspace, addressing the architectural goal of keeping worker tasks separate from true subagents while maintaining the same functionality.

## Problem Statement

Currently, the framework uses cmd-* subagents (e.g., `cmd-commit-and-push-analyzer`) as specialized workers for commands. These are registered as subagents but are really just task workers that:
- Only get invoked by specific commands
- Don't need automatic discovery
- Clutter the agents folder
- Confuse the distinction between true subagents and task workers

## Solution: Task Template Pattern

### Architecture Overview (Framework Development Workspace)

```
~/.lpclaude/ (this project root)
├── agents/                  # Global agents (via ~/.claude symlink)
│   ├── memory-keeper.md     # True subagents (proactive, discoverable)
│   ├── documentation-auditor.md
│   └── cmd-*.md            # TO BE REMOVED - migrated to tasks/
├── tasks/                   # Task worker templates (NEW)
│   ├── commit-analyzer.md
│   ├── security-scanner.md
│   ├── file-validator.md
│   └── ...
├── commands/               # Global commands (via ~/.claude symlink)
│   └── git/
│       └── commit-and-push.md  # Will use tasks/ templates
└── .claude/                # Project-local maintenance commands
    └── commands/maintenance/
```

### Key Differences

| Aspect | cmd-* Subagents | Task Templates |
|--------|-----------------|----------------|
| **Location** | `agents/cmd-*.md` | `tasks/*.md` (project root) |
| **Registration** | Registered as subagents | Not registered, just files |
| **Discovery** | Appear in agents list | Hidden from agents list |
| **Invocation** | `Task(subagent_type="cmd-xyz")` | `Task(prompt=Read("tasks/template.md"))` |
| **Context** | Fixed at definition | Dynamic at invocation |
| **Maintenance** | Mixed with true subagents | Clearly separated |
| **Scope** | Global (via ~/.claude symlink) | Project-specific tasks folder |

## Implementation Pattern

### Step 1: Create Task Template

Instead of `agents/cmd-commit-analyzer.md`:

```markdown
---
name: cmd-commit-analyzer
description: Analyzes files for commit grouping
tools: Read, LS, Glob, Grep
---
[System prompt content]
```

Create `tasks/commit-analyzer.md`:

```markdown
# Commit Analysis Task

You are a specialized file analysis agent...
[System prompt content - no YAML needed]
```

### Step 2: Update Command Implementation

#### Before (using cmd-* subagent):

```markdown
---
name: /git:commit-and-push
allowed-tools: Task, Bash
---

Analyze files using parallel workers:

1. Invoke cmd-commit-analyzer subagent:
   ```
   Task(
     subagent_type="cmd-commit-and-push-analyzer",
     description="Analyze files",
     prompt="Analyze these files: [file list]"
   )
   ```
```

#### After (using task template):

```markdown
---
name: /git:commit-and-push  
allowed-tools: Read, Task, Bash
---

Analyze files using task templates:

1. Load template and invoke task:
   ```
   # Read the task template
   template = Read("tasks/commit-analyzer.md")
   
   # Invoke with template as prompt
   Task(
     subagent_type="general-purpose",
     description="Analyze files",
     prompt=template + "\n\nContext:\n" + file_list
   )
   ```
```

## Migration Steps

### For Each cmd-* Subagent:

1. **Extract System Prompt**
   - Copy everything after the YAML frontmatter
   - Save to `tasks/[name].md` (project root)

2. **Update Command**
   - Add `Read` to allowed-tools
   - Change Task invocation pattern:
     - From: `subagent_type="cmd-xyz"`
     - To: `prompt=Read("tasks/xyz.md") + context`

3. **Remove Old Subagent**
   - Delete `agents/cmd-*.md` file
   - Verify command still works

4. **Test Thoroughly**
   - Execute the command
   - Verify same functionality
   - Check parallel execution still works

## Benefits Achieved

### 1. **Cleaner Organization**
- `agents/` contains only true subagents
- Task workers clearly separated
- Easier to understand system architecture

### 2. **Better Maintainability**
- Task templates in dedicated `tasks/` folder at project root
- No confusion about what's a "real" subagent
- Simpler mental model

### 3. **Enhanced Flexibility**
- Templates can be dynamically modified
- Context injection is more explicit
- Same template can be used with different contexts

### 4. **Reduced Namespace Pollution**
- Agent list only shows actual subagents
- No cmd-* entries cluttering the list
- Clearer distinction of component types

## Example Migration

### Original cmd-* Subagent
File: `agents/cmd-commit-and-push-analyzer.md`

```markdown
---
name: cmd-commit-and-push-analyzer
description: Analyzes git changes
model: haiku
tools: Read, LS, Glob, Grep
---

You are a specialized agent for analyzing changed files...
[200 lines of prompt]
```

### Migrated Task Template
File: `tasks/commit-analyzer.md`

```markdown
# Git Commit Analyzer

You are a specialized agent for analyzing changed files...
[Same 200 lines of prompt]
```

### Updated Command Usage

```markdown
# In /git:commit-and-push command

## Parallel Analysis Phase

Read task templates and execute in parallel:

1. Load templates:
   - analyzer_template = Read("tasks/commit-analyzer.md")
   - security_template = Read("tasks/security-scanner.md")
   - validator_template = Read("tasks/validator.md")

2. Execute tasks in parallel:
   - Task(prompt=analyzer_template + context, subagent_type="general-purpose")
   - Task(prompt=security_template + context, subagent_type="general-purpose")
   - Task(prompt=validator_template + context, subagent_type="general-purpose")
```

## Performance Considerations

- **No Performance Impact**: Task execution speed remains the same
- **Slightly More I/O**: Reading template files, but negligible
- **Same Parallelization**: Can still run multiple tasks concurrently
- **Model Selection**: Use `general-purpose` for haiku-equivalent performance

## Rollback Plan

If issues arise:
1. Keep backup of cmd-* agents
2. Revert command changes
3. Re-add agents to agents/ folder
4. Both patterns can coexist during transition

## FAQ

**Q: Can task templates use specific models like haiku?**
A: Use `subagent_type="general-purpose"` which typically uses a fast model.

**Q: What about tool permissions?**
A: The Task's subagent_type determines available tools. Use appropriate agent type.

**Q: Can templates be shared across commands?**
A: Yes! That's a benefit - multiple commands can use the same template.

**Q: Do templates need YAML frontmatter?**
A: No, they're just markdown files with the prompt content.

## Current cmd-* Agents to Migrate

Based on current inventory:
1. `cmd-commit-and-push-analyzer`
2. `cmd-commit-and-push-security`
3. `cmd-commit-and-push-validator`
4. `cmd-commands-normalize-analyzer`
5. `cmd-capture-session-analyzer`
6. `cmd-learn-analyzer`
7. `cmd-review-subagent-ecosystem-analyzer`
8. `cmd-jobs-auto-improve-scanner`
9. `cmd-create-command-validator`
10. `cmd-jobs-do-worker`

## Conclusion

The task template pattern provides a cleaner separation between true subagents (discoverable, proactive) and task workers (command-specific, hidden). This migration improves code organization without sacrificing functionality or performance.