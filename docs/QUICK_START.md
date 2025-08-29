# Quick Start Guide

Start developing Claude Code components in 2 minutes.

## Installation
```bash
./setup.sh                 # Creates symlinks to make components globally available
./rebuild_claude_md.sh     # Compiles directives (run after changes)
```

## Creating Components - The Fast Way

### Create an Agent
```bash
/agents                    # Interactive agent creator
```
Then optimize: `"Please optimize the agent I just created"`

### Create a Command
```bash
/commands:create           # Interactive command creator
```
Then optimize: `"Please optimize the command I just created"`

## Testing Your Work
- **Test agents**: Use Task tool with the agent name
- **Test commands**: Type the slash command
- **Changes propagate immediately** via symlinks (no rebuild needed)

## Most Common Tasks

| Task | Command/Action |
|------|---------------|
| Create new agent | `/agents` then optimize |
| Create new command | `/commands:create` then optimize |
| Update directives | Edit in `directives/` then run `./rebuild_claude_md.sh` |
| Test a component | Use Task tool (agents) or slash command (commands) |
| Fix "not triggering" | Run optimizer: `"Optimize agents/my-agent.md"` |

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