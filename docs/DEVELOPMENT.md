# Development Guide

## About This Guide

**This shows how I develop and test components for my personal Claude Code configuration.** Use these patterns as inspiration for your own setup, but adapt them to your workflow.

This is NOT documentation for a framework - it's examples from one person's configuration.

## Creating Components

### Create a Command (Automated)
```bash
/commands:create                          # Interactive wizard provided by this repo
```
**Value**: Guides you through best practices, ensures proper structure

### Create an Agent (Manual)
Add a `.md` file to `agents/` with YAML frontmatter:

```yaml
---
name: agent-name
description: Clear description. MUST BE USED PROACTIVELY when [trigger keywords].
tools: [Read, Write, Edit]    # No Task tool for agents
---

Your agent instructions here...
```

**Value**: Agents activate automatically based on conversation keywords

### Command Structure
```yaml
---
description: What it does
argument-hint: "[optional-arg]"
allowed-tools: Read, Write, Edit, Task, LS, Glob, Grep
---

Command instructions here...
```

**Value**: Commands can use Task tool for parallel execution

## Directives

**Build command:** `./rebuild_claude_md.sh`  
**Run after:** Adding/modifying/deleting directive files  
**Location:** `directives/` folder  
**Output:** `CLAUDE_global_directives.md` (auto-generated)

## Testing Your Components

- **Agents:** Trigger naturally in conversation (e.g., mention "security" for hack-spotter)
- **Commands:** Type the slash command directly
- **Test first:** Copy individual components to test before deploying all

Test in real scenarios to ensure components work as expected

## Version Control

**Commit:** All `.md` files, scripts, docs  
**Ignore:** `.local.md`, `.local.json`, generated files

## Quick Troubleshooting

**Agent not triggering?**
- Add "MUST BE USED PROACTIVELY" to description
- Run through optimizer

**Command not found?**
- Check namespace structure
- Verify file was copied: `ls -la ~/.claude/commands/`

**Changes not showing?**
- Directives: Run `./rebuild_claude_md.sh` and copy result
- Components: Ensure you copied updated files to ~/.claude/

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for detailed solutions.