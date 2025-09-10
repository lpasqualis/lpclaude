# Architecture

## Dual .claude System

### Global (`~/.claude/` - Symlinked)
- Available in ALL projects
- Created by `./setup.sh`
- Points to this repository
- Instant updates via symlinks

### Local (`.claude/` - This Repo)
- Framework maintenance only
- Contains meta-commands
- Not available in other projects
- Keeps framework tools isolated

## Visual Architecture
```
Your Development Environment
│
├── ~/.claude/                      # GLOBAL: Available everywhere
│   ├── agents/ ────────────────┐   # (symlinks to this repo)
│   ├── commands/ ──────────────┤
│   └── resources/ ─────────────┤
│                               │
├── /path/to/this/repository/ ◄─┘   # FRAMEWORK: Development workspace
│   ├── agents/                     # Source of global agents
│   ├── commands/                   # Source of global commands  
│   ├── resources/                  # Source of documentation
│   ├── .claude/                    # LOCAL: Framework-only tools
│   │   └── commands/maintenance/   # Meta-commands for framework
│   └── setup.sh                    # Creates the symlinks
│
└── /path/to/other/projects/        # OTHER PROJECTS
    └── (automatically use ~/.claude) # Have access to all your tools
```

## Repository Structure

```
├── agents/          # Global agents (symlinked)
├── commands/        # Global commands (symlinked)
├── workers/         # Parallel processing templates
├── directives/      # Behavior modifiers
├── resources/       # Framework documentation
├── .claude/         # Local maintenance commands
├── setup.sh        # Creates symlinks
└── rebuild_claude_md.sh  # Compiles directives
```

## Key Design Decisions

### Why Symlinks?
- **Instant updates**: Edit once, available everywhere immediately
- **Single source**: No version conflicts or sync issues
- **Easy management**: Simple setup.sh script handles everything
- **Clean uninstall**: Just remove symlinks, no residue

### Why Dual Configuration?
- **Isolation**: Framework maintenance tools don't pollute user projects
- **Clear boundaries**: Global tools vs local utilities
- **Safe development**: Test changes without affecting other projects

### Component Roles & Value
- **Agents**: Auto-activate on keywords, handle specialized tasks without user intervention
- **Commands**: Execute complex workflows, can orchestrate parallel operations via Task
- **Workers**: Enable 10x speedup through parallel processing
- **Directives**: Enforce consistent coding standards across all projects