# Migration Guide: Converting cmd-* Subagents to Task Templates in Other Projects

## Overview

This guide helps you migrate existing projects from the cmd-* subagent pattern to the cleaner task template pattern. This is for projects that use the standard `.claude/` directory structure (not the framework development workspace).

## Quick Migration (Automated)

### Using the Migration Command

A Claude Code command is available that automates the entire migration process:

```bash
# In any Claude Code session within your project, run:
/lpclaude:cmd-agents-to-tasks-migration

# With options:
/lpclaude:cmd-agents-to-tasks-migration --no-delete  # Keep original files
/lpclaude:cmd-agents-to-tasks-migration --dry-run    # Preview changes only
/lpclaude:cmd-agents-to-tasks-migration --backup-only # Just create backups
```

The command will:
1. ✅ Detect your project structure automatically
2. ✅ Create timestamped backups of all files
3. ✅ Extract system prompts from cmd-* agents
4. ✅ Create task templates in appropriate location
5. ✅ Update all command references
6. ✅ Add Read tool to commands that need it
7. ✅ Optionally delete old cmd-* files
8. ✅ Provide detailed migration report

## Manual Migration Steps

If you prefer to migrate manually or need to handle special cases:

### Step 1: Create Tasks Directory

```bash
mkdir -p .claude/tasks
```

### Step 2: Identify cmd-* Agents

```bash
ls .claude/agents/cmd-*.md
```

### Step 3: Migrate Each Agent

For each cmd-* agent:

1. **Extract the system prompt** (everything after the YAML frontmatter):
   ```bash
   # For a single file
   awk '/^---$/{count++} count==2{flag=1; next} flag' \
     .claude/agents/cmd-commit-analyzer.md > \
     .claude/tasks/commit-analyzer.md
   ```

2. **Remove the `cmd-` prefix** from the filename when saving to tasks/

### Step 4: Update Commands

Find commands that reference cmd-* agents:

```bash
grep -r "cmd-.*-analyzer\|cmd-.*-worker\|cmd-.*-validator" .claude/commands/
```

Update each reference:

#### Before:
```markdown
Use Task tool with subagent_type: 'cmd-commit-analyzer'
```

#### After:
```markdown
Read template: `template = Read('.claude/tasks/commit-analyzer.md')`
Use Task tool with `subagent_type: 'general-purpose'` and template as prompt
```

### Step 5: Test Commands

Test each updated command to ensure it works correctly:

```bash
# In Claude Code, test your commands
/your:command test
```

### Step 6: Clean Up

Once verified, delete the old cmd-* agents:

```bash
rm .claude/agents/cmd-*.md
```

## Common Patterns to Update

### Pattern 1: Simple Task Invocation

**Before:**
```markdown
- Use Task tool with subagent_type: 'cmd-analyzer-name'
```

**After:**
```markdown
- Read template: Read('.claude/tasks/analyzer-name.md')
- Use Task with subagent_type: 'general-purpose' and template as prompt
```

### Pattern 2: Parallel Task Execution

**Before:**
```markdown
Execute parallel analysis:
1. Invoke cmd-security-scanner for security analysis
2. Invoke cmd-performance-analyzer for performance checks
3. Invoke cmd-quality-checker for code quality
```

**After:**
```markdown
Execute parallel analysis:
1. Load templates:
   - security_template = Read('.claude/tasks/security-scanner.md')
   - performance_template = Read('.claude/tasks/performance-analyzer.md')
   - quality_template = Read('.claude/tasks/quality-checker.md')
2. Execute with Task tool using subagent_type: 'general-purpose'
```

### Pattern 3: In Command YAML

**Before:**
```yaml
---
name: /analyze:code
allowed-tools: Task, Read, Bash
---
```

**After:**
```yaml
---
name: /analyze:code
allowed-tools: Task, Read, Bash  # Read is now required to load templates
---
```

## Directory Structure

### Before Migration:
```
.claude/
├── agents/
│   ├── cmd-analyzer.md
│   ├── cmd-validator.md
│   └── memory-keeper.md    # True subagent (keep)
└── commands/
    └── analyze.md
```

### After Migration:
```
.claude/
├── agents/
│   └── memory-keeper.md    # Only true subagents remain
├── commands/
│   └── analyze.md          # Updated to use task templates
└── tasks/                  # NEW directory
    ├── analyzer.md
    └── validator.md
```

## Troubleshooting

### Empty Task Files

If task files are empty after migration, the YAML extraction may have failed. Try this alternative:

```bash
# Alternative extraction method
sed -n '/^---$/,/^---$/d; /^<!--.*-->$/d; p' \
  .claude/agents/cmd-agent.md | sed '/^$/d' > \
  .claude/tasks/agent.md
```

### Commands Not Working

Ensure:
1. The command has `Read` in its `allowed-tools`
2. Task template paths are correct (`.claude/tasks/` not `tasks/`)
3. The `general-purpose` subagent type is used

### Task Template Not Found

Check:
- File exists in `.claude/tasks/`
- Filename matches (removed `cmd-` prefix)
- Path in command is correct

## Benefits After Migration

1. **Cleaner Agent List**: No more cmd-* entries cluttering `/agents` output
2. **Better Organization**: Clear separation between true subagents and task workers
3. **Easier Maintenance**: Task templates grouped in dedicated folder
4. **Consistent Pattern**: All projects use the same structure

## Example: Complete Migration

Here's a real example of migrating a `cmd-test-runner` agent:

### Original Agent (.claude/agents/cmd-test-runner.md):
```markdown
---
name: cmd-test-runner
description: Runs tests in isolation for parallel execution
tools: Bash, Read
model: haiku
---

You are a test runner that executes test suites...
[System prompt content]
```

### Migrated Task Template (.claude/tasks/test-runner.md):
```markdown
You are a test runner that executes test suites...
[System prompt content - no YAML needed]
```

### Updated Command:
```markdown
# Before
Execute tests using Task with subagent_type: 'cmd-test-runner'

# After  
template = Read('.claude/tasks/test-runner.md')
Task(subagent_type: 'general-purpose', prompt: template + context)
```

## Best Practices

1. **Always backup** before migrating
2. **Test incrementally** - migrate and test one command at a time
3. **Keep task templates focused** - they should do one thing well
4. **Document the migration** in your project's README or CLAUDE.md
5. **Commit after testing** - ensure everything works before committing

## Using the Migration Command in Your Project

Since the `/lpclaude:cmd-agents-to-tasks-migration` command is globally available (via the `~/.claude/commands/` symlink), you can use it in any project:

1. Open Claude Code in your project directory
2. Run `/lpclaude:cmd-agents-to-tasks-migration`
3. Follow the prompts and review the migration report
4. Test your commands to ensure they work correctly

## Questions?

If you encounter issues not covered here:
1. Check the original migration guide in the framework workspace
2. Run `/lpclaude:cmd-agents-to-tasks-migration --dry-run` to preview changes
3. Test with a simple cmd-* agent first before complex ones
4. Check the backup directory if you need to restore files