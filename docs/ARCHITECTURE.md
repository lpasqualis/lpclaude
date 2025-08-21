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
├── tasks/           # Parallel processing templates
├── directives/      # Behavior modifiers
├── resources/       # Framework documentation
├── .claude/         # Local maintenance commands
├── docs/           # Project documentation
├── setup.sh        # Creates symlinks
└── rebuild_claude_md.sh  # Compiles directives
```

## Key Design Decisions

### Why Symlinks?
- Instant global updates
- Single source of truth
- No synchronization needed
- Easy uninstall

### Why Dual Configuration?
- Framework tools stay isolated
- Clean separation of concerns
- No pollution of regular projects

### Component Roles
- **Agents**: Specialized workers (no Task tool)
- **Commands**: User workflows (can use Task)
- **Task Templates**: Parallel processing
- **Directives**: Behavior modifiers