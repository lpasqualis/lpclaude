# Architecture

## About This Document

**This describes how I organize my personal Claude Code configuration.** It's one approach among many possible ways to structure these files. Use it as inspiration for your own organization.

## Dual .claude System

### Global (`~/.claude/`)
- Available in ALL projects
- Can be populated by:
  - Manually copying files from this repo (recommended)
  - Using symlinks via `./setup.sh` (advanced users only)
- Your personal Claude Code configuration directory

### Local (`.claude/` - This Repo)
- Repository maintenance only
- Contains meta-commands for managing this configuration
- Not available in other projects
- Keeps maintenance tools isolated

## Visual Architecture
```
Your Development Environment
│
├── ~/.claude/                      # GLOBAL: Available everywhere
│   ├── agents/                     # Your agents (copied or symlinked)
│   ├── commands/                   # Your commands (copied or symlinked)
│   └── resources/                  # Your resources (copied or symlinked)
│                               │
├── /path/to/this/repository/ ◄─┘   # REPOSITORY: Configuration source
│   ├── agents/                     # Source of global agents
│   ├── commands/                   # Source of global commands  
│   ├── resources/                  # Source of documentation
│   ├── .claude/                    # LOCAL: Repository-only tools
│   │   └── commands/maintenance/   # Meta-commands for this repo
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
├── resources/       # Research and documentation
├── .claude/         # Local maintenance commands
├── setup.sh        # Creates symlinks
└── rebuild_claude_md.sh  # Compiles directives
```

## Key Design Decisions

### Installation Options

#### Option 1: Manual Copying (Recommended)
- **Mix and match**: Combine components from this repo with your own
- **Safe**: No risk of overwriting existing configurations
- **Selective**: Choose exactly what you want
- **Control**: You decide when to update components

#### Option 2: Symlinks (Advanced Users Only)
- **All-or-nothing**: Replaces entire folders
- **Central updates**: Edit once in the repo, available everywhere
- **Clean uninstall**: Remove symlinks, your personal config remains intact
- **Risk**: Can accidentally replace existing configurations

### Why Dual Configuration?
- **Isolation**: Repository maintenance tools don't pollute user projects
- **Clear boundaries**: Global tools vs local utilities
- **Safe development**: Test changes without affecting other projects

### Component Roles & Value
- **Agents**: Auto-activate on keywords, handle specialized tasks without user intervention
- **Slash Commands**: Execute complex workflows, can orchestrate parallel operations via Task
- **Workers**: Enable 10x speedup through parallel processing
- **Directives**: Enforce consistent coding standards across all projects