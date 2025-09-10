# Claude Code Components Library

A curated personal configuration for Claude Code containing agents, commands, and tools. Once installed via symbolic links to ~/.claude/, these components become available in all your projects.

## What's Included

### Agents
- **completion-verifier** - Verifies task completion claims
- **delegate** - Delegates tasks to external LLMs
- **documentation-auditor** - Audits documentation against code
- **hack-spotter** - Reviews code for security issues and technical debt
- **implan-auditor** - Reviews implementation plans for completeness

### Slash Commands

#### Git & Version Control
- `/git:commit-and-push` - Intelligent commits with semantic versioning
- `/git:rewrite-commit-descriptions` - Improve commit messages

#### Documentation
- `/docs` - Documentation utilities
- `/docs:capture-session` - Document work for team handoff
- `/docs:capture-strategy` - Capture strategic decisions
- `/docs:readme-audit` - Audit and optimize README files
- `/pdf2md` - Convert PDF to Markdown

#### Planning & Implementation
- `/implan:create` - Generate implementation plans
- `/implan:execute` - Execute implementation plans
- `/postmortem` - Generate incident postmortems

#### Job Queue Management
- **addjob** - Queue tasks (Python utility, also has supporting agent)
- `/jobs:do` - Execute queued jobs in parallel
- `/jobs:auto-improve` - Enhance job descriptions for better execution
- `/jobs:queue-learnings` - Queue learnings for processing

#### Code Quality & Validation
- `/hackcheck` - Check for code hacks and shortcuts
- `/doublecheck` - Verify implementation completeness
- `/commands:validate` - Validate code or configurations
- `/simplify` - Simplify complex code or text

#### Knowledge Management
- `/learn` - Add insights to CLAUDE.md or extract from conversation
- `/claude:optimize-md` - Optimize CLAUDE.md files
- `/question` - Answer questions without taking action

#### Framework Development
- `/commands:create` - Interactive command creator
- `/add-parallelization` - Add parallel processing to commands
- `/optimize` - General optimization command
- `/subagents:optimize` - Optimize subagent definitions
- `/subagents:review-ecosystem` - Analyze agent interactions
- `/worker:run` - Run worker templates

#### VS Code Integration
- `/vs:settings-help` - VS Code settings assistance
- `/vs:tint-workspace` - Tint VS Code workspace

### Hooks
- **guard-cd** - Prevents Claude from changing directories and losing context
- **show-cwd** - Shows current working directory

### Output Styles
- **html-documentation** - HTML formatted documentation output
- **yaml-structured** - YAML structured data output

### Utilities
- **Global directives** - Coding standards and patterns via CLAUDE.md

## Usage

- **Agents** activate automatically based on keywords in your conversation
- **Slash commands** are typed directly (e.g., `/git:commit-and-push`)
- **addjob** queues tasks from terminal, then `/jobs:do` executes them in parallel

## How It Works

This repository uses symbolic links to make all components available globally:

```
~/.claude/                         This Repository
├── agents/ ───────→           ~/.lpclaude/agents/
├── commands/ ─────→           ~/.lpclaude/commands/
├── directives/ ───→           ~/.lpclaude/directives/
├── hooks/ ────────→           ~/.lpclaude/hooks/
├── mcp/ ──────────→           ~/.lpclaude/mcp/
├── output-styles/ →           ~/.lpclaude/output-styles/
├── resources/ ────→           ~/.lpclaude/resources/
├── utils/ ────────→           ~/.lpclaude/utils/
├── workers/ ──────→           ~/.lpclaude/workers/
├── settings.json ─→           ~/.lpclaude/settings/settings.json
├── statusline.sh ─→           ~/.lpclaude/statusline/statusline.sh
└── CLAUDE.md ─────→           ~/.lpclaude/directives/CLAUDE_global_directives.md
```

**Result**: Agents, commands, and tools you add or modify here become available in ALL your projects immediately.

## Installation Options

### Option 1: Full Installation (Recommended)
Install everything via symbolic links - all components become available globally:

```bash
git clone https://github.com/lpasqualis/lpclaude.git ~/.lpclaude
cd ~/.lpclaude
./setup.sh
```

This creates symbolic links from `~/.claude/` to this repository, giving you the complete curated collection.

### Option 2: Selective Installation
Cherry-pick specific components by manually copying them to your `~/.claude/` directory:

```bash
# Example: Install only specific agents
cp ~/.lpclaude/agents/hack-spotter.md ~/.claude/agents/

# Example: Install only certain commands
cp ~/.lpclaude/commands/git/commit-and-push.md ~/.claude/commands/git/

# Example: Install specific hooks
cp ~/.lpclaude/hooks/guard-cd.sh ~/.claude/hooks/
```

**Note:** With selective installation, you're responsible for:
- Creating the necessary subdirectories in `~/.claude/`
- Maintaining and updating these files manually
- Resolving any dependencies between components

### Optional: Make addjob Available System-Wide

To use the `addjob` utility from any directory:

```bash
echo "alias addjob='python3 ~/.claude/utils/addjob'" >> ~/.zshrc
source ~/.zshrc
```


## Documentation

### Quick Start
- **[Getting Started](docs/QUICK_START.md)** - 2-minute setup guide
- **[Component Reference](docs/REFERENCE.md)** - Complete list of agents and commands
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues and solutions

### Deep Dives
- **[Architecture Guide](docs/ARCHITECTURE.md)** - Technical design and structure
- **[Development Guide](docs/DEVELOPMENT.md)** - Create your own extensions
- **[Advanced Patterns](docs/ADVANCED_PATTERNS.md)** - Parallel processing and complex workflows
- **[Best Practices](resources/)** - Research and patterns


## Quick Reference

| Task | Action |
|------|--------|
| Install everything | `./setup.sh` |
| Create new agent | Add `.md` file to `agents/` with YAML frontmatter |
| Create new command | Add `.md` file to `commands/namespace/` |
| Update global directives | `./rebuild_claude_md.sh` |
| Make addjob available | `alias addjob='python3 ~/.claude/utils/addjob'` |

## Contributing

This collection grows through community contributions. To add your own agents and commands:

1. Fork this repository
2. Create your agents/commands following the patterns in [Development Guide](docs/DEVELOPMENT.md)
3. Test thoroughly in your own projects
4. Submit a pull request

## License

MIT - See LICENSE file for details
