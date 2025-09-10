# Quick Start Guide

Get up and running with this curated Claude Code configuration.

## Why Use This Repository

**Problem**: Every Claude Code session starts fresh, requiring you to re-explain project conventions, preferences, and workflows.

**Solution**: This repository provides a maintained collection of agents, commands, and tools that work across ALL your projects, giving Claude consistent capabilities and knowledge.

## Installation
```bash
git clone https://github.com/lpasqualis/lpclaude.git ~/.lpclaude
cd ~/.lpclaude
./setup.sh                 # Creates symlinks to ~/.claude/
```

That's it! All components are now available in every Claude Code session.

## What You Get

### Immediate Productivity Gains
- **Git workflows**: `/git:commit-and-push` for intelligent commits
- **Knowledge capture**: `/learn` to save insights across sessions
- **Parallel execution**: `/jobs:do` to run queued tasks concurrently
- **Code quality**: `hack-spotter` agent auto-detects security issues
- **Documentation**: `/docs:capture-session` for handoff documentation

## Creating Your Own Components

### Create a Command
```bash
/commands:create           # Interactive command creator (provided by this repo)
```

### Create an Agent
Create a `.md` file in `agents/` with YAML frontmatter:
```yaml
---
name: my-agent
description: What it does (include trigger keywords)
tools: [Read, Write, Edit]
---

Agent instructions here...
```

## Most Common Tasks

| Task | How |
|------|-----|
| Create new command | `/commands:create` (provided by this repo) |
| Create new agent | Add `.md` file to `agents/` with YAML |
| Update global behavior | Edit `directives/` then run `./rebuild_claude_md.sh` |
| Queue a task | `addjob "task description"` in terminal |
| Execute queued tasks | `/jobs:do` in Claude Code |

## Key Files to Know
- `agents/` - Your custom agents (global)
- `commands/` - Your slash commands (global)
- `directives/` - Behavior modifiers
- `CLAUDE.md` - Project instructions (this repo)
- `workers/` - Parallel processing templates

## Next Steps
- Read [ADVANCED_PATTERNS.md](ADVANCED_PATTERNS.md) for parallel processing and complex workflows
- See [REFERENCE.md](REFERENCE.md) for complete component inventory
- Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) when things don't work