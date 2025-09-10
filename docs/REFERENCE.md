# Component Reference

## About This Reference

**This documents the components in my personal Claude Code configuration.** These are tools I've built for my workflow - use them as examples and inspiration for your own setup.

This is NOT a product catalog - it's one person's collection of Claude customizations.

## Quick Guides
- [Subagents vs Commands vs Tasks](../resources/subagents_vs_commands_vs_tasks.md) - When to use each approach

## How to Choose Components

### When to Use Agents
- **Automatic activation needed** - When you want Claude to proactively help without explicit commands
- **Domain expertise** - When you need specialized knowledge (security, documentation, planning)
- **Background monitoring** - When you want continuous oversight of your work

**Example**: Use `hack-spotter` agent when you frequently work with security-sensitive code and want automatic reviews.

### When to Use Commands
- **Explicit control** - When you want to trigger functionality on-demand
- **Workflow automation** - When you have specific procedures to execute
- **Complex operations** - When you need parallel processing or multi-step workflows

**Example**: Use `/git:commit-and-push` command when you want intelligent commits but only when you explicitly request them.

### When to Use Workers
- **Parallel processing** - When you need to process multiple items simultaneously
- **Specialized analysis** - When commands need focused subtasks
- **Performance optimization** - When breaking work into concurrent pieces saves time

**Example**: The `/jobs:do` command uses workers to process multiple jobs in your queue simultaneously.

## Version Compatibility Matrix

| Component Type | Claude Code Version | Status | Notes |
|----------------|-------------------|--------|-------|
| **Agents** | v1.0+ | ✅ Full Support | YAML frontmatter required |
| **Commands** | v1.0+ | ✅ Full Support | Slash command syntax |
| **Workers** | v1.2+ | ✅ Full Support | Task tool integration needed |
| **Hooks** | v1.1+ | ✅ Full Support | Shell script execution |
| **Output Styles** | v1.3+ | ✅ Full Support | Formatting templates |
| **MCP Integration** | v1.4+ | ⚠️ Beta | Experimental features |

**Framework Requirements:**
- **Minimum**: Claude Code v1.0, Git, Basic shell
- **Recommended**: Claude Code v1.4+, jq, modern terminal
- **Optional**: VS Code, Homebrew (macOS), llm tool for delegation

## Agents

### Content Management
| Agent | Purpose | Triggers On | Skill Level | Use When |
|-------|---------|------------|-------------|----------|
| `documentation-auditor` | Update docs | "documentation", "docs outdated" | Beginner | Docs get stale frequently |

### Development Support  
| Agent | Purpose | Triggers On | Skill Level | Use When |
|-------|---------|------------|-------------|----------|
| `implan-auditor` | Audit plans | "audit implan", "check completeness" | Intermediate | Complex implementations |
| `hack-spotter` | Security review | "security", "review code", "hacks" | Beginner | Security-critical code |
| `addjob` | Task queuing | "add job", "defer", "schedule" | Beginner | Batch processing needs |

**Agent Selection Guide:**
- **New to AI coding?** Start with `hack-spotter` (automatic security reviews)
- **Managing complex projects?** Add `documentation-auditor` and `implan-auditor`
- **Heavy workload?** Include `addjob` for task queueing

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

### Global Components Location
```
~/.claude/
├── agents/          # Your agents (copied from or symlinked to repo)
├── commands/        # Your commands (copied from or symlinked to repo)
├── resources/       # Resources (copied from or symlinked to repo)
└── CLAUDE.md        # Global directives
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

## Component Templates

### Agent Template
Use this template when creating new agents:

```markdown
---
name: my-domain-agent
description: MUST BE USED PROACTIVELY when [trigger conditions]. [What it does in 1-2 sentences].
model: sonnet
color: blue
---

# [Agent Name] Agent

You are an expert in [domain/specialty]. Your role is to [primary function].

## When to Activate
- User mentions [keyword1], [keyword2], or [keyword3]
- User asks about [specific scenarios]
- [Automatic activation conditions]

## Your Expertise
- [Domain knowledge area 1]
- [Domain knowledge area 2] 
- [Specific skills/capabilities]

## Process
1. [Step 1 of your standard process]
2. [Step 2 with specific actions]
3. [Final step and deliverables]

## Quality Standards
- [Standard 1 you always enforce]
- [Standard 2 with specific criteria]
- Always [behavior you consistently exhibit]
```

### Command Template
Use this template when creating new commands:

```markdown
---
name: /namespace:command-name
description: [What this command accomplishes in 1 sentence]
argument-hint: "[arg1] [optional-arg2]"
allowed-tools: Read, Write, Edit, Task, LS, Glob, Grep
---

# [Command Name]

[Brief description of what this command does and why it's useful]

## Usage
\`/namespace:command-name [arguments]\`

## What It Does
1. [Primary action/analysis performed]
2. [Secondary actions if any]
3. [Final output/deliverable]

## Arguments
- **arg1**: [Required] - [Description of what this argument does]
- **optional-arg2**: [Optional] - [Description, include default behavior if omitted]

## Examples
\`\`\`
/namespace:command-name "example input" 
# Expected output: [description]
\`\`\`

## Output
- [File(s) created/modified with locations]
- [Console feedback provided]
- [Any side effects or state changes]

## Requirements
- [Any prerequisites or dependencies]
- [File/directory structure expectations]

Follow exactly and without stopping:

[Detailed step-by-step instructions for Claude to execute this command]
```

### Worker Template
Use this template when creating worker templates for parallel processing:

```markdown
# [Worker Purpose] Worker

You are a focused worker responsible for [specific task within larger workflow].

## Context
You are part of a parallel processing system handling [broader task context].

## Your Specific Role
[Exactly what this worker analyzes/processes/handles]

## Input Format
You will receive: [description of input format/structure]

## Process
1. [Specific step 1]
2. [Specific step 2] 
3. [Output formatting step]

## Output Format
Provide results in this exact structure:
\`\`\`
[Expected output format]
\`\`\`

## Quality Checks
- [Check 1 to perform]
- [Check 2 to validate]
- [Final verification step]

## Constraints
- [Limitation 1 to respect]
- [Time/scope boundaries]
- [What NOT to do]
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
./setup.sh                              # Create symlinks (advanced users only)
./rebuild_claude_md.sh                  # Compile directives
# Or manually copy individual files you want

# Creation (this repo provides)
/commands:create                        # Create command interactively

# Create agents manually
# Add .md file to agents/ with YAML frontmatter

# Maintenance (this repo only)
/maintenance:update-knowledge-base      # Update framework knowledge
```