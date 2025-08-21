# Development Guide

## Creating Components - Quick Reference

### Automated Creation (Recommended)

**Create an Agent:**
```bash
/agents                                    # Interactive wizard
"Optimize agents/my-new-agent.md"         # Auto-optimize after
```

**Create a Command:**
```bash
/commands:create                          # Interactive wizard  
"Optimize commands/namespace/command.md"   # Auto-optimize after
```

### Manual Creation

**Agent YAML:**
```yaml
---
name: agent-name
description: Clear description. MUST BE USED PROACTIVELY when [trigger].
model: sonnet    # haiku/sonnet/opus
---
```

**Command YAML:**
```yaml
---
name: /namespace:command
description: What it does
argument-hint: "[optional-arg]"
allowed-tools: Read, Write, Edit, Task, LS, Glob, Grep
---
```

Always optimize after creation!

## Directives

**Build command:** `./rebuild_claude_md.sh`  
**Run after:** Adding/modifying/deleting directive files  
**Location:** `directives/` folder  
**Output:** `CLAUDE_global_directives.md` (auto-generated)

## Automatic Optimization

Just ask naturally - optimizers trigger automatically:
- "Optimize my agent"
- "Improve this command"
- "Review for best practices"

**What gets optimized:**
- Agents: Descriptions, models, triggers, colors
- Commands: Permissions, arguments, placeholders

## Testing

- **Agents:** `Task(subagent_type: 'agent-name', prompt: 'test')`
- **Commands:** Type the slash command
- **Changes:** Propagate immediately via symlinks

## Version Control

**Commit:** All `.md` files, scripts, docs  
**Ignore:** `.local.md`, `.local.json`, generated files

## Quick Troubleshooting

**Agent not triggering?**
- Add "MUST BE USED PROACTIVELY" to description
- Run through optimizer

**Command not found?**
- Check namespace structure
- Verify symlinks: `ls -la ~/.claude/`

**Changes not showing?**
- Directives: Run `./rebuild_claude_md.sh`
- Components: Check you're editing in framework repo

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for detailed solutions.