# My Claude Code Configuration (Example Repository)

**This is my personal Claude Code configuration that I maintain in Git.** I'm sharing it publicly as an example of how to organize and version-control a Claude Code setup.

> **What this is:** My personal collection of agents, commands, and tools that I use across all my projects.
> 
> **What this isn't:** A framework or product to install. It's one person's configuration shared as a reference.

## Why I'm Sharing This

Claude Code supports personal configurations via `~/.claude/`, but there aren't many examples of how to organize and maintain them. This repository shows:

- **How I structure my configuration** for maintainability
- **How I use Git** to version control and sync across machines
- **Examples of agents, commands, and hooks** I've found useful
- **Patterns for organizing** a growing collection of Claude customizations

## How to Use This Repository

### As a Reference
Browse the repository to:
- See how to structure your own Claude configuration
- Get ideas for agents and commands you might want to create
- Learn the syntax and patterns for different component types
- Understand how various Claude Code features work together

### Copy Individual Components
If you find something useful:
1. Copy the specific file to your own `~/.claude/` directory
2. Customize it for your needs
3. Make it yours - don't just use my configuration as-is

### Fork as a Starting Point
To create your own configuration repository:
1. Fork this repo
2. Delete my specific configurations
3. Add your own agents, commands, and preferences
4. Maintain your own version-controlled Claude setup

## What's in My Configuration

Here's what I've built for my workflow (yours will be different):

- **Slash Commands** (30+) - My shortcuts for git, documentation, job processing, learning capture, VS Code theming
- **Agents** (10+) - Auto-triggering helpers I use for security reviews, documentation, task queueing
- **Workers** - Templates for parallel processing that speed up my multi-task workflows
- **Hooks** - Shell scripts that prevent me from making mistakes (like cd'ing to wrong directories)
- **Output Styles** - How I prefer Claude to format responses for different contexts
- **Status Line** - My terminal prompt integration showing session context
- **Utility Scripts** - Helper tools like my `addjob` task queuing system
- **Directives** - My coding standards and preferences compiled into CLAUDE.md
- **Resources** - Research and documentation I've collected about Claude Code patterns
- **Organization** - How I structure everything to stay maintainable

> **New to Claude Code?** Claude Code is Anthropic's official CLI that brings Claude's AI capabilities directly to your terminal. It natively supports personal configurations via `~/.claude/` - this repository is just one example of how to use that feature.

## Prerequisites

Before installing this configuration, you'll need:

### 1. Claude Code Installed
Claude Code is Anthropic's official CLI for AI-powered coding assistance.
- **Installation Guide**: [claude.ai/code](https://claude.ai/code)
- **Quick Check**: Run `claude --version` in your terminal

### 2. Understanding ~/.claude Directory
- This is Claude Code's built-in location for "personal" configurations and tools
- It applies to all projects you work on your machine
- This repository uses symlinks to replace specific folders (agents, commands, etc.)
- Non sym-linked parts of your .claude configuration remain untouched
- This separation ensures the repo can be updated without affecting the rest of your personal configurations

### 3. System Requirements
- **OS**: macOS, Linux, or Windows with WSL
- **Tools**: Git and basic terminal familiarity
- **Space**: ~10MB for the configuration files
- **Optional**: VS Code for visual editing (any text editor works)

> **First time using Claude Code?** Start with the Quick Try section below to test individual components before full installation.

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
- `/jobs:auto-improve` - Natural language project improvement that continuously finds and fixes issues
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

- **Agents** activate automatically based on keywords in your conversation with Claude
- **Slash commands** are typed directly in Claude Code (e.g., `/git:commit-and-push`)
- **addjob** (shell utility) queues tasks from your terminal, then `/jobs:do` (slash command) executes them in parallel in Claude

## How It Works

If you choose to use the standard setup (you don't have to), this repository uses **selective symbolic links** to integrate with Claude Code's configuration system:

```
~/.claude/                         This Repository (symlinked folders)
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
├── CLAUDE.md ─────→           ~/.lpclaude/directives/CLAUDE_global_directives.md
│
├── [Your personal files remain here, untouched]
├── memory/                    (Your personal memory files)
├── .claude.json               (Your personal project settings)
└── [Other personal configs]   (Any other personal configurations)
```

**Important: Symlinks Replace Entire Folders**: When you use symlinks (via setup.sh), each symlinked folder completely replaces that folder in `~/.claude/`. For example, symlinking `agents/` means ALL agents come from this repo - you can't mix repo agents with your own agents in that folder.

**If you want to pick and choose specific components**:
- Don't use the symlink setup
- Instead, manually copy individual files you want from this repo to your `~/.claude/` folders
- This lets you combine components from this repo with your own custom components

**Benefits of the symlink approach**:
- Keep the repository cleanly separated from your personal configurations
- Allow your `~/.claude/` to evolve with your personal settings, memory files, and project-specific configs
- Enable easy updates to the shared components without touching your personal data
- Make uninstallation simple - just remove the symlinks, your personal config remains


### Component Interaction Flow

```
Your Claude Code Session
         ┃
         ▼
   ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
   │   AGENTS    │     │  COMMANDS   │     │   HOOKS     │
   │ (automatic) │     │ (on-demand) │     │(lifecycle)  │
   └─────────────┘     └─────────────┘     └─────────────┘
         ┃                       ┃                   ┃
         ▼                       ▼                   ▼
   ┌─────────────────────────────────────────────────────┐
   │              WORKERS (parallel)                     │
   │ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐   │
   │ │Task 1   │ │Task 2   │ │Task 3   │ │Task N   │   │
   │ └─────────┘ └─────────┘ └─────────┘ └─────────┘   │
   └─────────────────────────────────────────────────────┘
         ┃
         ▼
   ┌─────────────┐
   │ GLOBAL      │
   │ DIRECTIVES  │ ← Your persistent preferences and standards
   │ (CLAUDE.md) │
   └─────────────┘

Flow Examples:
• You mention "security" → hack-spotter AGENT activates → Reviews code automatically
• You type "/git:commit-and-push" → COMMAND launches → WORKERS analyze in parallel → Result
• You start Claude Code → HOOKS initialize → Global directives load → Context established
```

## If You Want to Try My Components

### Option 1: Copy Individual Pieces (Recommended)
**Browse and copy only what's useful to you.**

Cherry-pick specific components:

```bash
# First, clone the repo (if not already done)
git clone https://github.com/lpasqualis/lpclaude.git ~/.lpclaude

# Create directories as needed
mkdir -p ~/.claude/agents ~/.claude/commands/git

# Copy only the components you want
cp ~/.lpclaude/agents/hack-spotter.md ~/.claude/agents/
cp ~/.lpclaude/commands/git/commit-and-push.md ~/.claude/commands/git/
cp ~/.lpclaude/hooks/guard-cd.sh ~/.claude/hooks/
```

**Benefits of selective installation:**
- Mix components from this repo with your own custom agents/commands
- Keep some folders under your control while using others from this repo
- Test individual components before committing to the full set

**Drawbacks:**
- Manual updates - you'll need to copy files again when the repo updates
- Potential dependency issues if components rely on each other
- No automatic compilation of directives


### Option 2: Use My Entire Setup (Not Recommended)

**Only do this if you really want MY exact configuration.** This is how I set up my own machines, but you probably want your own configuration, not mine.


```bash
# Clone the repository
git clone https://github.com/lpasqualis/lpclaude.git ~/.lpclaude
cd ~/.lpclaude

# Run setup (creates symlinks and installs optional dependencies)
./setup.sh
```

#### What setup.sh Does:
1. **Attempts to create symbolic links** in `~/.claude/` pointing to this repository:
   - **Claude-standard folders** (recognized by Claude Code):
     - `agents/` - Auto-triggering AI agents
     - `commands/` - Slash commands
     - `output-styles/` - Response formatting styles
     - `hooks/` - Event-triggered shell scripts
     - `CLAUDE.md` - Shared memory file
   - **Supporting folders**:
     - `directives/` - Compiled preferences and standards
     - `resources/` - Reference documents and guides
     - `utils/` - Helper scripts (like addjob)
     - `workers/` - Parallel processing templates
     - `mcp/` - Model Context Protocol servers
   - **Configuration files**:
     - `settings.json` - Claude Code settings
     - `statusline.sh` - Terminal prompt integration
   - **Only creates symlinks if the target doesn't exist**
   - **If folders/files already exist**: Skips them entirely (your content is preserved)
   - Everything else in `~/.claude/` remains completely untouched
2. **Installs optional dependencies** (if not present):
   - `brew` - Package manager (macOS only)
   - `jq` - JSON processor used by some commands
   - `llm` - Tool for delegating to external LLMs
   - Modern terminal fonts for better display
3. **Compiles directives** into a single CLAUDE.md file
4. **Validates installation** and reports any issues

#### Important: Handling Existing Folders
- **If you have existing `agents/` or `commands/` folders**: The setup will skip them and warn you
- **To use this repo with existing folders**, you have three options:
  1. Backup and move your existing folders: `mv ~/.claude/agents ~/.claude/agents.backup`
  2. Use selective installation (Option 2) to manually copy specific files
  3. Merge your content into this repo and fork it


### Optional: Make addjob Available System-Wide

To use the `addjob` utility from any directory, add an alias to your shell configuration:

**For zsh (default on modern macOS):**
```bash
echo "alias addjob='python3 ~/.claude/utils/addjob'" >> ~/.zshrc
source ~/.zshrc
```

**For bash:**
```bash
echo "alias addjob='python3 ~/.claude/utils/addjob'" >> ~/.bashrc
source ~/.bashrc
```

**For fish:**
```bash
echo "alias addjob='python3 ~/.claude/utils/addjob'" >> ~/.config/fish/config.fish
source ~/.config/fish/config.fish
```

## Creating Your Own Configuration Repository

**Want to create your own version-controlled Claude configuration?** Here's how I organize mine:

### Starting Your Own

1. **Create Your Repository**
   ```bash
   # Start fresh with your own structure
   mkdir ~/my-claude-config
   cd ~/my-claude-config
   git init
   
   # Create the folders you need
   mkdir agents commands hooks output-styles directives utils
   ```

2. **Build Your Components**
   - Start with one or two agents/commands you'll actually use
   - Test them by copying to `~/.claude/` first
   - Once they work, commit them to your repo
   - Gradually build up your collection

3. **How I Sync Across Machines**
   - I use symlinks from `~/.claude/` to my repo
   - When I update the repo on one machine, I pull on others
   - This keeps all my machines consistent
   - You might prefer a different approach

4. **Ideas for Your Configuration**
   - **Automate what you do repeatedly** - That's what commands are for
   - **Create agents for your review process** - Code review, security, docs
   - **Add hooks for your common mistakes** - Prevent errors before they happen
   - **Build your own directives** - Your coding standards, not mine

### Best Practices for Your Configuration

- **Start Small**: Begin with 2-3 agents and commands, grow organically
- **Document Everything**: Each component should explain its purpose
- **Version Control**: Commit your customizations for team sharing
- **Test First**: Verify components work before team-wide deployment

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

