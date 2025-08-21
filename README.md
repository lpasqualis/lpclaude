# Claude Framework Development Workspace

**Supercharge Claude Code with custom agents, commands, and automation that work across ALL your projects.**

Transform Claude Code into your personal AI development assistant by creating custom extensions that automate repetitive tasks, enforce best practices, and streamline your workflow. Write once, use everywhere.

## What Can You Build?

### Custom Agents - Specialized AI Workers
```bash
# Automatically spot security issues in your code
Task(subagent_type="hack-spotter", prompt="Review auth.js")

# Generate comprehensive implementation plans
Task(subagent_type="implan-generator", prompt="Plan user dashboard feature")

# Optimize your documentation
Task(subagent_type="documentation-auditor", prompt="Audit API docs")
```

### Slash Commands - Instant Automation
```bash
# Intelligently commit with semantic versioning
/git:commit-and-push

# Extract and save learnings from your session
/memory:learn

# Create implementation plans from conversations
/implan:create

# Capture session work for handoff
/docs:capture-session
```

### Job Queue System - Never Lose Focus
```bash
# Queue tasks without interrupting your flow
addjob "Refactor the authentication module"
addjob "Update API documentation" 
addjob "Run comprehensive test suite"
addjob "Review and fix linting issues"

# Later, execute all queued jobs in parallel with a single command
/jobs:do

# The system processes up to 10 jobs simultaneously, 
# maintaining context and handling each task independently
```

### Global Directives - Shape Claude's Behavior
- Enforce coding standards across all projects
- Set project-specific conventions
- Define custom workflows and patterns

## Quick Start (2 minutes)

### 1. Install Framework

```bash
git clone [repository-url] ~/claude-framework
cd ~/claude-framework
./setup.sh
```

That's it! Your custom agents and commands are now available in every project.

### 2. Create Your First Extension (The Smart Way)

**The framework helps you create and optimize its own components!**

**Create a custom command** using the framework's own command creator:
```bash
# Use the framework's command creator - it guides you through everything!
/commands:create

# Follow the interactive prompts to:
# - Choose namespace and name
# - Define requirements
# - Set appropriate tool permissions
# The command creator ensures best practices automatically
```

**Create a custom agent** using Claude's built-in agent creator:
```bash
# Use Claude's built-in agent creation command
/agents

# This will:
# - Guide you through agent definition
# - Create properly formatted YAML frontmatter
# - Set up the agent in the correct location
```

**Optimize automatically** - Just ask Claude!
```bash
# After creating any agent or command, simply say:
"Please optimize my new agent"
# or
"Optimize the command I just created"

# This automatically triggers the framework's optimizers:
# - command-optimizer for commands
# - subagent-optimizer for agents
# They'll ensure best practices, proper structure, and maximum effectiveness
```

**Why this approach is better:**
- ✅ No manual file creation or YAML editing
- ✅ Built-in best practices enforcement
- ✅ Automatic optimization for maximum effectiveness
- ✅ The framework improves itself!

## The Framework That Improves Itself

### 🧠 Intelligent Optimizers - Transform Your Extensions

The framework includes sophisticated optimizers that don't just fix issues - they **transform your extensions into high-performance, parallel-capable systems**:

#### Command Optimizer - Makes Commands Lightning Fast
```bash
# After creating any command, just say:
"Please optimize my command"

# The command-optimizer will:
# ⚡ Analyze for parallelization opportunities
# ⚡ Automatically create specialized subagents for parallel execution
# ⚡ Convert sequential operations into concurrent workflows
# ⚡ Set up proper tool permissions and model selection
# ⚡ Transform monolithic commands into efficient, distributed systems

# Example: A command that analyzes 50 files sequentially becomes
# a parallel system processing 10 files simultaneously!
```

#### Subagent Optimizer - Ensures Reliable Invocation
```bash
# After creating any agent, just say:
"Optimize this agent"

# The subagent-optimizer will:
# 🎯 Enhance descriptions with trigger keywords for automatic invocation
# 🎯 Optimize model selection (haiku for speed, opus for complexity)
# 🎯 Validate YAML frontmatter and proactive settings
# 🎯 Ensure proper tool permissions are granted
# 🎯 Add semantic colors and improve discoverability
```

**The Magic**: These optimizers include "MUST BE USED PROACTIVELY" in their descriptions - they trigger automatically when you mention optimization. They don't just fix problems; they architect solutions that leverage Claude's full parallel processing capabilities!

## Featured Extensions

### Productivity Boosters
- **`/git:commit-and-push`** - Intelligent commits with semantic versioning
- **`/memory:learn`** - Extract and save session learnings
- **`/docs:capture-session`** - Document work for seamless handoff
- **`/implan:create`** - Generate detailed implementation plans

### Code Quality & Performance
- **`hack-spotter`** - Detect technical debt and security issues
- **`documentation-auditor`** - Keep docs in sync with code
- **`command-optimizer`** - Transform commands into parallel-capable systems
  - Automatically creates specialized worker subagents
  - Converts sequential workflows to concurrent execution
  - Optimizes for up to 10x performance improvement
- **`subagent-optimizer`** - Maximize agent effectiveness
  - Ensures reliable automatic invocation
  - Optimizes model selection and tool permissions
  - Enhances discoverability through keyword optimization

### Development Workflow

#### 🚀 Powerful Job Queue System - Work Without Interruptions
- **`addjob` utility** - Queue tasks for batch processing without breaking your flow
  - Add tasks to a queue while you stay focused on current work
  - Defer complex operations for later execution
  - Create job files that capture full context and requirements
- **`/jobs:do`** - Execute all queued jobs in parallel (up to 10 simultaneously)
  - Process your entire job queue with a single command
  - Automatic parallel execution for maximum efficiency
  - Perfect for end-of-session cleanup, bulk operations, or deferred tasks
- **`/subagents:review-ecosystem`** - Analyze agent interactions

## How It Works

Once installed, the framework uses symlinks to make your extensions globally available:

```
Your ~/.claude/                    This Repository
├── agents/ ───────→           agents/
├── commands/ ─────→           commands/
└── directives/ ───→           directives/
```

**Result**: Edit here, use everywhere. Changes take effect instantly.

## Documentation

### Quick Start
- **[Getting Started](docs/QUICK_START.md)** - 2-minute setup guide
- **[Component Reference](docs/REFERENCE.md)** - Complete list of agents and commands
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues and solutions

### Deep Dives
- **[Architecture Guide](docs/ARCHITECTURE.md)** - Technical design and structure
- **[Development Guide](docs/DEVELOPMENT.md)** - Create your own extensions
- **[Advanced Patterns](docs/ADVANCED_PATTERNS.md)** - Parallel processing and complex workflows
- **[Migration Guide](docs/MIGRATION_GUIDE.md)** - Upgrading from legacy patterns
- **[Best Practices](resources/)** - Research and patterns


## Quick Reference

| Task | Command |
|------|--------|
| Install framework | `./setup.sh` |
| Create new agent | Add to `agents/`, test with Task tool |
| Create new command | Add to `commands/namespace/` |
| Update directives | `./rebuild_claude_md.sh` |
| Setup addjob utility | `alias addjob='python3 ~/.claude/utils/addjob'` |

## Contributing

This framework thrives on community contributions. To add your own extensions:

1. Fork this repository
2. Create your agents/commands following the patterns in [Development Guide](docs/DEVELOPMENT.md)
3. Test thoroughly
4. Submit a pull request

## License

MIT - See LICENSE file for details
