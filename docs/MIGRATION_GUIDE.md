# Migration Guide

Transitioning from legacy patterns to modern Claude Framework architecture.

## Legacy Pattern → Modern Pattern

### CMD-* Agents → Task Templates

**Legacy (deprecated):**
```markdown
# agents/cmd-analyzer.md
---
name: cmd-analyzer
model: haiku
---
Analyze specific files...
```

**Modern:**
```markdown
# tasks/command-analyzer.md
# No YAML frontmatter
Analyze specific files...
```

**Migration steps:**
1. Move agent content to `tasks/` directory
2. Remove YAML frontmatter
3. Update commands to use `Read()` + `Task()`
4. Delete old cmd-* agent files

### Direct Agent Invocation → Task Template Pattern

**Legacy:**
```markdown
# In command
Use Task tool to invoke cmd-worker agent with this context...
```

**Modern:**
```markdown
# In command
template = Read('tasks/worker.md')
Task(subagent_type: 'general-purpose', prompt: template + context)
```

### Hardcoded Parallel Workers → Dynamic Templates

**Legacy:**
```markdown
# Command spawns specific named agents
Invoke cmd-commit-analyzer for file analysis...
Invoke cmd-security-checker for security...
```

**Modern:**
```markdown
# Command loads templates dynamically
analyzers = [
    Read('tasks/commit-analyzer.md'),
    Read('tasks/security-checker.md')
]
for template in analyzers:
    Task(subagent_type: 'general-purpose', prompt: template + context)
```

## Deprecated Features

### Removed YAML Fields

| Field | Status | Replacement |
|-------|--------|------------|
| `proactive: true` | Removed | Use "MUST BE USED PROACTIVELY" in description |
| `model:` in commands | Problematic | Check token limits before using |
| `max_thinking_tokens:` | Not supported | Remove from all definitions |

### Obsolete Patterns

| Pattern | Why Deprecated | Modern Approach |
|---------|---------------|-----------------|
| cmd-* agents | Poor architecture | Task templates |
| Nested Task calls | Framework limitation | Single-level parallelization |
| Agents with Task tool | Violates hierarchy | Only commands get Task |
| Manual optimization | Error-prone | Use optimizer agents |

## Common Migration Scenarios

### Scenario 1: Parallel Processing Command

**Before:**
- Command invokes multiple cmd-* agents
- Each agent has own YAML definition
- Difficult to maintain and update

**After:**
- Command loads task templates
- Templates are pure prompts
- Easy to modify and test

### Scenario 2: Proactive Agent

**Before:**
```yaml
---
name: my-agent
proactive: true
---
```

**After:**
```yaml
---
name: my-agent
description: |
  Expert that MUST BE USED PROACTIVELY when...
---
```

### Scenario 3: Complex Workflow

**Before:**
- Single monolithic command
- Sequential processing only
- Poor performance

**After:**
- Orchestration command with Task tool
- Parallel task templates
- 10x performance improvement

## Step-by-Step Migration Process

### 1. Audit Existing Components
```bash
# Find legacy patterns
grep -r "cmd-" agents/
grep -r "proactive:" agents/ commands/
grep -r "model:" commands/
```

### 2. Create Task Templates
```bash
# For each cmd-* agent:
1. Copy content to tasks/{purpose}.md
2. Remove YAML frontmatter
3. Ensure self-contained logic
```

### 3. Update Commands
```bash
# Replace agent invocations with template loading:
1. Add Task to allowed-tools
2. Replace agent references with Read() + Task()
3. Test parallel execution
```

### 4. Run Optimizers
```bash
# Optimize all migrated components:
"Optimize all agents in agents/"
"Optimize all commands in commands/"
```

### 5. Clean Up
```bash
# Remove deprecated files:
rm agents/cmd-*.md
# Update documentation
# Commit changes
```

## Validation Checklist

After migration, verify:

- [ ] No cmd-* agents remain
- [ ] No `proactive:` fields in YAML
- [ ] Commands using templates work correctly
- [ ] Parallel execution performs as expected
- [ ] All components pass optimization
- [ ] Documentation updated
- [ ] Tests pass

## Rollback Plan

If migration causes issues:

1. Symlinks ensure immediate rollback:
   ```bash
   git checkout main -- agents/ commands/
   ```

2. Revert task templates:
   ```bash
   git checkout main -- tasks/
   ```

3. Rebuild directives:
   ```bash
   ./rebuild_claude_md.sh
   ```

## Getting Help

- Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues
- Review [ADVANCED_PATTERNS.md](ADVANCED_PATTERNS.md) for modern patterns
- Test components incrementally
- Use optimizer agents to validate changes