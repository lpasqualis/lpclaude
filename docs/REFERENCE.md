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
| Command | Purpose | Usage |
|---------|---------|-------|
| `/commands:create` | Create new commands | Interactive wizard |
| `/commands:optimize` | Optimize command definitions | Improves command quality |
| `/commands:normalize` | Standardize structure | Batch normalization |
| `/subagents:optimize` | Optimize agent definitions | Improves agent quality |
| `/subagents:review-ecosystem` | Analyze agent overlap | Ecosystem health check |
| `/claude:optimize-md` | Optimize CLAUDE.md files | Scope-based organization |

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

Templates for parallel processing (in `workers/` directory):

| Template | Used By | Purpose |
|----------|---------|---------|
| `capture-session-analyzer` | `/docs:capture-session` | Session analysis |
| `commit-analyzer` | `/git:commit-and-push` | File grouping |
| `commit-and-push-security` | `/git:commit-and-push` | Security scan |
| `jobs-do-worker` | `/jobs:do` | Parallel job processing |
| `review-subagent-ecosystem-analyzer` | `/subagents:review-ecosystem` | Agent analysis |

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
| Task Templates | command-purpose | `commit-analyzer.md` |
| Directives | descriptive_names | `python_standards.md` |

## Quick Command Reference

```bash
# Setup
./setup.sh                              # Install symlinks
./rebuild_claude_md.sh                  # Compile directives

# Creation
/agents                                 # Create agent
/commands:create                        # Create command

# Optimization
"Optimize agents/my-agent.md"           # Optimize agent
"Optimize commands/my/command.md"       # Optimize command

# Maintenance (this repo only)
/maintenance:update-knowledge-base      # Update framework knowledge
```