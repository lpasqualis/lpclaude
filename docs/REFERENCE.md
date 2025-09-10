# Component Reference

Quick lookup for all framework components.

## Quick Guides
- [Subagents vs Commands vs Tasks](../resources/subagents_vs_commands_vs_tasks.md) - When to use each approach

## Agents

### Content Management
| Agent | Purpose | Triggers On |
|-------|---------|------------|
| `documentation-auditor` | Update docs | Documentation outdated/inconsistent |

### Development Support
| Agent | Purpose | Triggers On |
|-------|---------|------------|
| `implan-auditor` | Audit implementation plans | "audit implan", completeness check |
| `hack-spotter` | Find technical debt | Code review, security audit |
| `addjob` | Create deferred tasks | "add job", "defer", "schedule" |

## Commands

### Core Management
| Command | Purpose | Value |
|---------|---------|-------|
| `/commands:create` | Create new commands | Interactive wizard guides best practices |
| `/commands:optimize` | Optimize command definitions | Adds parallelization and improves quality |
| `/subagents:optimize` | Optimize agent definitions | Ensures reliable triggering |
| `/subagents:review-ecosystem` | Analyze agent overlap | Prevents duplicate functionality |
| `/claude:optimize-md` | Optimize CLAUDE.md files | Organizes directives by scope |

### Documentation
| Command | Purpose | Output |
|---------|---------|--------|
| `/docs:capture-session` | Document work session | `docs/dev_notes/` |
| `/docs:capture-strategy` | Create project context | Main docs folder |
| `/docs:readme-audit` | Optimize README | Updated README.md |

### Git Operations
| Command | Purpose | Features |
|---------|---------|----------|
| `/git:commit-and-push` | Smart commits | Semantic commits, grouping |

### Planning & Execution
| Command | Purpose | Location |
|---------|---------|----------|
| `/implan:create` | Create implementation plan | `docs/implans/` |
| `/implan:execute` | Resume implementation | Finds active plans |
| `/jobs:do` | Process job queue | `jobs/` folder |

### Memory
| Command | Purpose | Captures |
|---------|---------|----------|
| `/learn` | Add insights or extract learnings | CLAUDE.md management |

## Worker Templates

Templates for parallel processing (in `workers/` directory subdirectories):

| Template Path | Used By | Purpose |
|--------------|---------|---------|
| `docs-capture-session-workers/analyzer.md` | `/docs:capture-session` | Session analysis |
| `git-commit-and-push-workers/analyzer.md` | `/git:commit-and-push` | File grouping |
| `git-commit-and-push-workers/security.md` | `/git:commit-and-push` | Security scan |
| `git-commit-and-push-workers/validator.md` | `/git:commit-and-push` | Validation |
| `jobs-do-workers/parallel-job-worker.md` | `/jobs:do` | Parallel job processing |
| `subagents-review-ecosystem-workers/analyzer.md` | `/subagents:review-ecosystem` | Agent analysis |
| `commands-add-parallelization-workers/analyzer.md` | `/add-parallelization` | Parallelization analysis |
| `commands-create-workers/command-validator.md` | `/commands:create` | Command validation |

## File Structure

### Global Components (Symlinked)
```
~/.claude/
├── agents/          → {repo}/agents/
├── commands/        → {repo}/commands/
├── resources/       → {repo}/resources/
└── CLAUDE.md        → {repo}/CLAUDE_global_directives.md
```

### Repository Layout
```
{repo}/
├── agents/          # Agent definitions
├── commands/        # Command definitions
├── workers/         # Worker templates
├── directives/      # Behavior modifiers
├── resources/       # Documentation
├── .claude/         # Local maintenance
└── docs/           # Project docs
```

## YAML Frontmatter Reference

### Agent Frontmatter
```yaml
---
name: agent-name
description: Clear description. MUST BE USED PROACTIVELY when...
model: sonnet    # haiku, sonnet, or opus
color: blue      # semantic color
---
```

### Command Frontmatter
```yaml
---
name: /namespace:command
description: What this command does
argument-hint: "[optional-arg]"
allowed-tools: Read, Write, Edit, Task, LS, Glob, Grep
---
```

## Tool Permission Groups

### Read-Only
```yaml
allowed-tools: Read, LS, Glob, Grep
```

### File Modification
```yaml
allowed-tools: Read, Write, Edit, MultiEdit, LS, Glob, Grep
```

### Orchestration
```yaml
allowed-tools: Task, Read, Write, Edit, LS, Glob, Grep
```

### Full Access
```yaml
allowed-tools: Task, Read, Write, Edit, Bash, LS, Glob, Grep, WebSearch, WebFetch
```

## Naming Conventions

| Type | Convention | Example |
|------|-----------|---------|
| Agents | lowercase-hyphenated | `hack-spotter.md` |
| Commands | namespace/command | `git/commit-and-push.md` |
| Worker Templates | command-workers/purpose | `git-commit-workers/analyzer.md` |
| Directives | descriptive_names | `python_standards.md` |

## Quick Command Reference

```bash
# Setup
./setup.sh                              # Install symlinks
./rebuild_claude_md.sh                  # Compile directives

# Creation (this repo provides)
/commands:create                        # Create command interactively

# Create agents manually
# Add .md file to agents/ with YAML frontmatter

# Maintenance (this repo only)
/maintenance:update-knowledge-base      # Update framework knowledge
```