**Version:** 2.0  
**Date:** August 8, 2025  
**Author:** Lorenzo Pasqualis  

# Claude Framework Development Workspace

**This is the central repository for developing and maintaining custom Claude Code agents, commands, and directives that are used globally across all your projects.**

## 🎯 What This Repository Does

This repository serves as your personal Claude Code customization framework. Once set up, the agents and commands you develop here become available in EVERY project you work on. Think of it as your personal Claude Code extension library.

## 🏗️ Architecture: The Dual .claude Folder System

This project implements a sophisticated dual-configuration system that separates global tools from framework maintenance tools:

### 1️⃣ Global Configuration (`~/.claude/` - Symlinked)
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

### 2️⃣ Project-Local Configuration (`.claude/` - In This Repo)
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

### 📊 Visual Architecture
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

## 🚀 Installation & Setup

### First-Time Setup

1. **Clone this repository** to a permanent location:
```bash
git clone [repository-url] ~/claude-framework
cd ~/claude-framework
```

2. **Run the setup script** to install globally:
```bash
./setup.sh
```

This will:
- ✅ Automatically run `rebuild_claude_md.sh` to compile directives
- ✅ Create symlinks from `~/.claude/` to this repository
- ✅ Make all agents and commands available globally
- ✅ Skip any existing symlinks (non-destructive)
- ✅ Report what was installed

### After Setup

Once installed:
- **In any project**: Your custom agents and commands are automatically available
- **In this repository**: You also get special maintenance commands from `.claude/`
- **Changes are instant**: Edit an agent here, it's immediately updated everywhere

#### Setting Up the addjob Alias (Recommended)

After running setup.sh, the `addjob` utility is available at `~/.claude/utils/addjob`. To make it easily accessible from anywhere, add this alias to your shell profile (`~/.bashrc`, `~/.zshrc`, or `~/.bash_profile`):

```bash
alias addjob='python3 ~/.claude/utils/addjob'
```

Then reload your shell:
```bash
source ~/.zshrc  # or ~/.bashrc or ~/.bash_profile
```

This allows you to create job files from anywhere:
```bash
addjob my-task                      # Create a sequential job
addjob --parallel worker-task       # Create a parallel job
echo "Task content" | addjob --stdin task-name  # Create from stdin
```

For more addjob usage examples and options, see `utils/README.md`.

#### Important: Building CLAUDE_global_directives.md

The `CLAUDE_global_directives.md` file is **automatically generated** and should **NEVER be edited manually**. This file is built by the `rebuild_claude_md.sh` script, which:

1. **Collects all directive files** from the `directives/` directory (excluding .gitignore and local files)
2. **Aggregates their content** into a single comprehensive file
3. **Adds metadata** including build timestamp
4. **Creates the final CLAUDE_global_directives.md** file

**When to run rebuild_claude_md.sh:**
- Automatically runs when you execute `setup.sh`
- **Must be run manually** whenever you:
  - Add a new directive file to `directives/`
  - Modify any existing directive file
  - Delete a directive file

**How to run rebuild_claude_md.sh:**
```bash
# From the repository root
./rebuild_claude_md.sh
```

**Build process details:**
- The script scans for all `.md` files in `directives/` (except `.local.md` files which are ignored)
- Each directive file's content is included with a header indicating its source
- The resulting `CLAUDE_global_directives.md` serves as the master directive file when symlinked to `~/.claude/CLAUDE.md`
- Any manual edits to `CLAUDE_global_directives.md` will be lost on the next build

## Agents

### 1. Subagent Optimizer
**File:** `agents/subagent-optimizer.md`  
**Purpose:** Audits and enforces best practices on subagent definition files, optimizing structure, model selection, color assignment, and proactive directives.  
**Use Cases:**
- Refactoring agent descriptions for clarity and compliance
- Optimizing model selection based on task complexity (haiku/sonnet/opus)
- Assigning semantic colors based on agent function
- Adding proactive directives when appropriate
- Operates idempotently - only makes changes when necessary

### 3. Command Optimizer
**File:** `agents/command-optimizer.md`  
**Purpose:** Audits and enforces best practices on slash command definition files, optimizing frontmatter and prompt content only when necessary.  
**Use Cases:**
- Refactoring command descriptions for clarity and accuracy
- Auditing tool permissions for security compliance (Principle of Least Privilege)
- Improving argument hints and placeholder usage
- Ensuring proper use of placeholders like `{{selected_text}}`
- Checking latest documentation for updated best practices
- Operates idempotently - only makes changes when necessary

### 3. Implan Generator Agent
**File:** `agents/implan-generator.md`  
**Purpose:** A specialized implementation planning expert that creates comprehensive, actionable plans for software features and components.  
**Use Cases:**
- Breaking down complex development tasks into structured phases
- Creating detailed implementation plans with checkboxes and progress tracking
- Generating plans with agent instructions, phase breakdowns, testing requirements
- Starting new features, refactoring components, or organizing development work
- **Proactive**: Automatically triggered when implementation planning is needed

### 4. Memory Keeper Agent
**File:** `agents/memory-keeper.md`  
**Purpose:** Records NEW information, facts, decisions, or project-specific information in the CLAUDE.md file for long-term memory.  
**Use Cases:**
- Recording architectural decisions
- Establishing coding standards and conventions
- Documenting project-specific configurations
- Creating or updating CLAUDE.md files

### 5. Claude MD Optimizer Agent
**File:** `agents/claude-md-optimizer.md`  
**Purpose:** Optimizes and improves the quality, organization, and effectiveness of EXISTING CLAUDE.md files.  
**Use Cases:**
- Checking for contradictions and redundancies in CLAUDE.md
- Reorganizing content for better clarity
- Resolving conflicting instructions
- Improving overall file structure and formatting

### 6. Hack Spotter Agent
**File:** `agents/hack-spotter.md`  
**Purpose:** Reviews code for technical debt, shortcuts, hardcoded values, and brittle implementations.  
**Use Cases:**
- Analyzing code for hardcoded secrets and magic numbers
- Finding brittle logic and temporary workarounds
- Detecting disabled safeguards and workflow bypasses
- Identifying configuration workarounds
- Focuses on production code (not test code)

### 7. Implan Auditor Agent
**File:** `agents/implan-auditor.md`  
**Purpose:** Audits implementation plans (implans) for completeness, correctness, and compliance with requirements.  
**Use Cases:**
- Detecting incomplete implementations and stubs
- Finding TODOs and temporary implementations
- Ensuring implans meet all stated requirements
- Adding testing phases when needed
- Verifying compliance with project standards

### 8. Documentation Auditor Agent
**File:** `agents/documentation-auditor.md`  
**Purpose:** Comprehensively audits and updates documentation to ensure accuracy and relevance.  
**Use Cases:**
- Assessing documentation accuracy against current codebase
- Identifying outdated or conflicting information
- Consolidating redundant documentation
- Ensuring code examples and API documentation are current
- Note: Excludes CLAUDE.md files (use specialized agents for those)

### 9. Addjob Agent
**File:** `agents/addjob.md`  
**Purpose:** Creates job files for deferred task execution using the addjob utility when tasks need to be scheduled for later processing.  
**Use Cases:**
- Scheduling complex operations for later execution
- Creating batch processing jobs
- Queueing related tasks for sequential or parallel execution
- Deferring work that doesn't need immediate execution
- Creating self-contained tasks that will run via `/jobs:do` command
- **Proactive**: Automatically triggered when tasks need to be deferred

## Command-Specific Subagents (cmd-*)

The repository includes specialized subagents designed to work in parallel with specific commands. These agents follow the `cmd-*` naming convention and are optimized for focused, specialized processing.

### 1. Session Analysis Agent
**File:** `agents/cmd-capture-session-analyzer.md`  
**Purpose:** Specialized agent for analyzing specific aspects of development sessions in parallel for capture-session and capture-strategy commands.  
**Use Cases:**
- Codebase structure analysis and architectural pattern identification
- Recent changes analysis and git history review
- Technical context analysis of specific files or code sections
- Problem domain analysis and requirement understanding
- **Model**: haiku (optimized for speed in parallel execution)

### 2. Commit Analysis Agent  
**File:** `agents/cmd-commit-and-push-analyzer.md`  
**Purpose:** Analyze changed files and classify them into logical commit groups with semantic commit types for the commit-and-push command.  
**Use Cases:**
- File classification into semantic commit categories (feat, fix, docs, etc.)
- Logical grouping of related files for coherent commits
- Priority assessment and commit ordering recommendations
- JSON-structured output for automated processing

### 3. Commit Security Agent
**File:** `agents/cmd-commit-and-push-security.md`  
**Purpose:** Analyze file contents for sensitive data, large binaries, and security concerns during commit preparation.  
**Use Cases:**
- Sensitive data detection (API keys, passwords, private keys)
- File size and type analysis for Git LFS recommendations
- Security risk assessment and anti-pattern identification
- Actionable security recommendations with risk levels

### 4. Commit Validator Agent
**File:** `agents/cmd-commit-and-push-validator.md`  
**Purpose:** Validate commit messages, file changes, and repository state before pushing changes.  
**Use Cases:**
- Commit message format validation against semantic conventions
- Change impact assessment and risk analysis
- Repository state verification and conflict detection
- Pre-push validation and quality gates

### 5. Command Validator Agent
**File:** `agents/cmd-create-command-validator.md`  
**Purpose:** Validate command definitions during command creation process.  
**Use Cases:**
- YAML frontmatter validation for required fields
- Command naming convention compliance
- Tool permission auditing for security best practices
- Command structure and format verification

### 6. Learning Analyzer Agent
**File:** `agents/cmd-learn-analyzer.md`  
**Purpose:** Extract and analyze learnings from development sessions for the learn command.  
**Use Cases:**
- Technical discovery identification and categorization
- Pattern recognition in development workflows
- Knowledge extraction for future reference
- Learning prioritization and organization

### 7. Ecosystem Analyzer Agent
**File:** `agents/cmd-review-subagent-ecosystem-analyzer.md`  
**Purpose:** Specialized analyzer for reviewing subagent ecosystem health and optimization opportunities.  
**Use Cases:**
- Individual agent analysis for clarity and appropriateness
- Cross-agent compatibility and overlap assessment
- Parallel execution for large agent ecosystems (up to 10 agents)
- Structured analysis output for ecosystem optimization

## Commands

### 1. Review Subagent Ecosystem Command
**File:** `commands/subagents/review-ecosystem.md`  
**Purpose:** Analyzes sub-agent definition files to identify ambiguities, overlaps, conflicts, and gaps in capabilities.  
**Output:** Comprehensive report with executive summary, detailed analysis table, and actionable recommendations for improving the agent ecosystem.

### 2. Capture Session Command
**File:** `commands/docs/capture-session.md`  
**Purpose:** Documents the complete status of work done in a session for seamless handoff to other agents.  
**Output Location:** `docs/dev_notes/` folder  
**Includes:**
- Problem statement
- Actions taken
- Key findings and technical insights
- Next steps and recommendations

### 3. Capture Strategy Command
**File:** `commands/docs/capture-strategy.md`  
**Purpose:** Creates a comprehensive project context document for any agent to pick up work without loss of context.  
**Output Location:** Main documents folder of the current project  
**Includes:**
- Problem statement and success criteria
- Strategy overview
- Phased implementation plan
- Document usage notes
- Technical notes

### 4. Commit and Push Command
**File:** `commands/git/commit-and-push.md`  
**Purpose:** Intelligently commits and pushes changes to git repository.  
**Features:**
- Reviews all changed files in the project
- Groups changes into logical commits
- Uses semantic commit notation
- Creates clear, concise commit messages
- Pushes to origin

### 5. Create Command Command
**File:** `commands/commands/create.md`  
**Purpose:** Interactive command creator that helps create new Claude Code commands.  
**Features:**
- Guides through command type selection (project vs personal)
- Helps define command requirements and details
- Creates properly formatted command files
- Provides templates and best practices

### 6. Learn Command
**File:** `commands/memory/learn.md`  
**Purpose:** Extracts and preserves important learnings from the current session for future reference.  
**Captures:**
- Technical discoveries and solutions
- Configuration and setup details
- Gotchas and pitfalls encountered
- Project-specific insights
- Workflow optimizations

### 7. Create Implan Command
**File:** `commands/implan/create.md`  
**Purpose:** Creates a comprehensive implementation plan from the current conversation context.  
**Features:**
- Analyzes conversation for requirements and approach
- Creates structured implementation plans
- Saves to `docs/implans/` directory
- Uses standardized naming convention
- Can update existing plans

### 8. Work on Implan Command
**File:** `commands/implan/execute.md`  
**Purpose:** Resumes work on an existing implementation plan.  
**Features:**
- Finds and loads active implementation plans
- Analyzes current progress and next steps
- Continues implementation based on plan
- Updates plan status as work progresses
- Handles multiple active plans

## 📁 Repository Structure

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
│   │   └── capture-strategy.md   # /docs:capture-strategy
│   ├── git/                       # Git operations
│   │   └── commit-and-push.md    # /git:commit-and-push
│   ├── implan/                    # Implementation plans
│   │   ├── create.md              # /implan:create
│   │   └── execute.md             # /implan:execute
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
├── CLAUDE.md                       # Project instructions for Claude
├── README.md                       # This file
├── setup.sh                        # Installation script
└── rebuild_claude_md.sh                        # Directive compiler
```

## 🔧 Development Workflow

### Creating New Components

#### New Agent
```bash
# 1. Create agent file
touch agents/my-new-agent.md

# 2. Add YAML frontmatter:
---
name: my-new-agent
description: Clear description for automatic invocation
proactive: true  # Optional
---

# 3. Test immediately
# Use Task tool with subagent_type: "my-new-agent"
```

#### New Command
```bash
# 1. Create command in appropriate namespace
touch commands/namespace/my-command.md

# 2. Add YAML frontmatter:
---
name: /namespace:my-command
description: What this command does
# NEVER add 'model' field - causes failure!
---

# 3. Test immediately
# Type: /namespace:my-command
```

### Testing Your Work

**In THIS repository:**
- Test agents: Use Task tool with the agent name
- Test commands: Type the slash command
- Test maintenance: Use `/maintenance:update-knowledge-base`

**In OTHER projects:**
- Your new agents/commands are immediately available
- No need to reinstall or update

### Maintenance Commands (Framework Only)

These commands are available ONLY when working in this repository:

#### `/maintenance:update-knowledge-base`
- Updates embedded Claude Code knowledge in optimizers
- Fetches latest official documentation
- Identifies components needing updates
- Run quarterly or after Claude Code releases

## 📚 Resources & Documentation

The `resources/` directory contains critical documentation:

### Best Practices Guides
- **`slash_commands_best_practices_research.md`** - Command patterns and anti-patterns
- **`subagent_invocation_research.md`** - Agent architecture and invocation
- **`commands_and_agents.md`** - Technical deep dive and constraints

### Knowledge Management
- **`knowledge-base-manifest.json`** - Tracks which components have embedded Claude Code knowledge
- Updated via `/maintenance:update-knowledge-base` command
- Ensures optimizers stay current with Claude Code updates

## 🎓 Understanding the System

### Why This Architecture?

1. **Global Availability**: Develop once, use everywhere
2. **Clean Separation**: Framework tools don't pollute regular projects
3. **Instant Updates**: Changes propagate immediately via symlinks
4. **Version Control**: Everything is tracked in git
5. **Maintenance Isolation**: Meta-commands only when needed

### Key Concepts

- **Agents**: Specialized AI workers for focused tasks
- **Commands**: User-triggered workflows with full context
- **Directives**: Behavioral modifications for Claude
- **cmd-* agents**: Parallel workers for command optimization
- **Maintenance commands**: Meta-tools for framework development

### Common Tasks

| Task | Command/Action |
|------|---------------|
| Install framework globally | `./setup.sh` |
| Update directives | `./rebuild_claude_md.sh` |
| Create new agent | Add to `agents/`, test with Task tool |
| Create new command | Add to `commands/namespace/`, test with slash |
| Update embedded knowledge | `/maintenance:update-knowledge-base` |
| Check what's installed | `ls -la ~/.claude/` |
