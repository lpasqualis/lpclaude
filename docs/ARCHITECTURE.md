# Architecture Documentation

## The Dual .claude Folder System

This project implements a sophisticated dual-configuration system that separates global tools from framework maintenance tools:

### Global Configuration (`~/.claude/` - Symlinked)
**What it is:** Your home directory's Claude configuration that makes agents/commands available everywhere.

**How it works:**
- Running `./setup.sh` creates symlinks from `~/.claude/` to this repository
- These symlinks make your custom agents and commands available in ALL projects
- Any changes you make here are immediately available globally

**What gets symlinked:**
```
~/.claude/agents/ → {this-repo}/agents/
~/.claude/commands/ → {this-repo}/commands/
~/.claude/resources/ → {this-repo}/resources/
~/.claude/CLAUDE.md → {this-repo}/CLAUDE_global_directives.md
```

### Project-Local Configuration (`.claude/` - In This Repo)
**What it is:** Special maintenance commands that are ONLY available when working on the framework itself.

**Why it exists:**
- Contains meta-commands for maintaining the framework
- These commands shouldn't be available in regular projects
- Includes specialized tools like `/maintenance:update-knowledge-base`

**Contents:**
```
.claude/
├── commands/
│   └── maintenance/           # Framework maintenance commands
│       └── update-knowledge-base.md
└── settings.local.json       # Local permissions (gitignored)
```

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
.
├── agents/                         # GLOBAL AGENTS (symlinked to ~/.claude/)
│   ├── claude-md-optimizer.md     # Optimizes CLAUDE.md files
│   ├── command-optimizer.md       # Optimizes command definitions
│   ├── subagent-optimizer.md      # Optimizes subagent definitions
│   ├── memory-keeper.md           # Manages long-term memory
│   ├── hack-spotter.md            # Detects technical debt
│   ├── addjob.md                  # Creates deferred job files
│   └── cmd-*.md                   # Command-specific parallel workers
│
├── commands/                       # GLOBAL COMMANDS (symlinked to ~/.claude/)
│   ├── commands/                  # Command management
│   │   ├── create.md              # /commands:create
│   │   └── normalize.md           # /commands:normalize
│   ├── docs/                      # Documentation
│   │   ├── capture-session.md    # /docs:capture-session
│   │   ├── capture-strategy.md   # /docs:capture-strategy
│   │   └── readme-audit.md       # /docs:readme-audit
│   ├── git/                       # Git operations
│   │   └── commit-and-push.md    # /git:commit-and-push
│   ├── implan/                    # Implementation plans
│   │   ├── create.md              # /implan:create
│   │   └── execute.md             # /implan:execute
│   ├── jobs/                      # Job management
│   │   └── do.md                  # /jobs:do
│   ├── memory/                    # Memory management
│   │   └── learn.md               # /memory:learn
│   └── subagents/                 # Subagent management
│       └── review-ecosystem.md    # /subagents:review-ecosystem
│
├── .claude/                        # LOCAL MAINTENANCE (this repo only)
│   ├── commands/
│   │   └── maintenance/
│   │       └── update-knowledge-base.md  # /maintenance:update-knowledge-base
│   └── settings.local.json        # Local permissions (gitignored)
│
├── resources/                      # DOCUMENTATION (symlinked to ~/.claude/)
│   ├── commands_and_agents.md     # Technical deep dive
│   ├── slash_commands_best_practices_research.md
│   ├── subagent_invocation_research.md
│   └── knowledge-base-manifest.json  # Tracks embedded knowledge
│
├── directives/                     # BEHAVIOR MODIFIERS
│   └── *.md                       # Compiled into CLAUDE_global_directives.md
│
├── docs/                          # Project documentation
│   ├── ARCHITECTURE.md           # This file
│   ├── COMPONENTS.md             # Complete component reference
│   └── DEVELOPMENT.md            # Development guide
│
├── CLAUDE.md                       # Project instructions for Claude
├── README.md                       # Entry point documentation
├── setup.sh                        # Installation script
└── rebuild_claude_md.sh           # Directive compiler
```

## Why This Architecture?

1. **Global Availability**: Develop once, use everywhere
2. **Clean Separation**: Framework tools don't pollute regular projects
3. **Instant Updates**: Changes propagate immediately via symlinks
4. **Version Control**: Everything is tracked in git
5. **Maintenance Isolation**: Meta-commands only when needed

## Key Architectural Decisions

### Symlink Approach
We use symlinks rather than copying files because:
- Changes are instantly reflected globally
- No synchronization needed
- Single source of truth
- Easy to uninstall (just remove symlinks)

### Dual Configuration
The dual `.claude` folder approach allows:
- Framework-specific tools to remain isolated
- Clean separation of concerns
- Prevention of meta-command pollution in regular projects
- Clear distinction between using and developing the framework

### Component Organization
- **Agents**: Isolated workers for specific tasks
- **Commands**: User-triggered workflows
- **Directives**: Behavioral modifications
- **Resources**: Shared documentation and knowledge