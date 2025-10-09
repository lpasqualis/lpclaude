# My Claude Code Configuration (Example Repository)

**This is my personal Claude Code configuration that I maintain in Git.** I'm sharing it publicly as an example of how to organize and version-control a Claude Code setup. This system works for me and my needs, but might not work for others. My requirements are:

1. **Make components available globally** - Have my slash commands, agents, hooks, etc. accessible across all projects I work on
2. **Source control everything** - Version control these components for history, backup, and evolution tracking
3. **Multi-machine sync** - Use the same setup on multiple machines and systems seamlessly
4. **Learn by doing** - Continue learning about agentic systems by experimenting with different patterns
5. **Share and improve** - Document my approach for others and gather feedback to improve

> **What this is:** My personal collection of agents, slash commands, and tools that I use across all my projects.
> 
> **What this isn't:** A framework or product to install. It's one person's configuration shared as a reference.

## Why I'm Sharing This

Claude Code supports personal configurations via `~/.claude/`, but there aren't many examples of how to organize and maintain them. This repository shows:

- **How I structure my configuration** for maintainability
- **How I use Git** to version control and sync across machines
- **Examples of agents, slash commands, and hooks** I've found useful
- **Patterns for organizing** a growing collection of Claude customizations

## Installation Options

### Option 1: Install as Plugin (Recommended)

The easiest way to use this configuration is via Claude Code's plugin system:

```bash
# Install directly from GitHub
/plugin install https://github.com/lpasqualis/lpclaude

# Or add the marketplace first, then browse and install
/plugin marketplace add lpasqualis/lpclaude
/plugin install lpclaude-config
```

**Benefits:**
- ✅ One-command installation
- ✅ Automatic updates via plugin system
- ✅ Easy to enable/disable without uninstalling
- ✅ No manual symlink management
- ✅ Works alongside your personal `~/.claude/` configs

**After installation**, restart Claude Code to load all components.

See [PLUGIN_INSTALL.md](PLUGIN_INSTALL.md) for detailed plugin documentation.

### Option 2: Traditional Setup (Manual Control)

For full control over files and symlinks:

```bash
git clone https://github.com/lpasqualis/lpclaude.git ~/.lpclaude
cd ~/.lpclaude
./setup.sh
```

See ["If You Want to Try My Components"](#if-you-want-to-try-my-components) section below for details.

### Option 3: Browse and Learn

**Not ready to install?** You can also:

#### As a Reference
Browse the repository to:
- See how to structure your own Claude configuration
- Get ideas for agents and slash commands you might want to create
- Learn the syntax and patterns for different component types
- Understand how various Claude Code features work together

#### Copy Individual Components
If you find something useful:
1. Copy the specific file to your own `~/.claude/` directory
2. Customize it for your needs
3. Make it yours - don't just use my configuration as-is

#### Fork as a Starting Point
To create your own configuration repository:
1. Fork this repo
2. Delete my specific configurations
3. Add your own agents, slash commands, and preferences
4. Maintain your own version-controlled Claude setup

## What's in My Configuration

Here's what I've built for my workflow (yours will be different):

- **Slash Commands** (30+) - My shortcuts for git, documentation, job processing, learning capture, VS Code theming
- **Agents** - Auto-triggering helpers I use for security reviews, documentation, task queueing
- **Workers** - My custom pattern: reusable task templates that slash commands can run in parallel (not a Claude feature)
- **Hooks** - Shell scripts that prevent me from making mistakes (like cd'ing to wrong directories)
- **Output Styles** - How I prefer Claude to format responses for different contexts
- **Status Line** - My terminal prompt integration showing session context
- **Utility Scripts** - Helper tools like my `addjob` task queuing system
- **Directives** - General directives split into numbered files, compiled into CLAUDE.md (see [Directives Compilation](#directives-compilation) below)
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
- `/postmortem` - Analyze session to identify and document issues for systematic fixing

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

#### Context & Memory Management  
- `/learn` - Add insights to CLAUDE.md or extract from conversation
- `/claude:optimize-md` - Optimize CLAUDE.md files
- `/question` - Answer questions without taking action
- `/docs:capture-session` - Document work for team handoff (preserves context)

#### Framework Development
- `/commands:create` - Interactive slash command creator
- `/add-parallelization` - Add parallel processing to slash commands
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


### Component Interaction

```
   ┌─────────────────────────────────────────────────────┐
   │            GLOBAL DIRECTIVES (CLAUDE.md)            │
   │         Loaded at startup, applies to everything    │
   └─────────────────────────────────────────────────────┘
                            ┃
                            ▼
   ┌─────────────────────────────────────────────────────┐
   │             Your Claude Code Session                │
   └─────────────────────────────────────────────────────┘
         ┃                  ┃                    ┃
         ▼                  ▼                    ▼
   ┌────────────┐    ┌──────────────┐    ┌─────────────┐
   │   AGENTS   │    │SLASH COMMANDS│    │    HOOKS    │
   │(automatic) │    │ (explicit /) │    │ (lifecycle) │
   └────────────┘    └──────────────┘    └─────────────┘
                            ┃
                   (some slash commands)
                            ▼
                  ┌──────────────────┐
                  │     WORKERS      │
                  │ (parallel tasks) │
                  └──────────────────┘

How Components Work:
• DIRECTIVES: Define behavior and standards for all interactions
• AGENTS: Auto-trigger on keywords (e.g., "security" → hack-spotter)
• SLASH COMMANDS: User types /command (e.g., /git:commit-and-push)
• HOOKS: Run at specific events (e.g., before shell commands)
• WORKERS*: My custom pattern - reusable task templates for parallel execution
• OUTPUT STYLES: Format Claude's responses (not shown)

*Note: Workers are not a Claude Code feature - they're my pattern for organizing
reusable task instructions that slash commands can execute in parallel via the Task tool,
without the overhead of creating full agents that consume context space.
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
- Mix components from this repo with your own custom agents/slash commands
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
  2. Use selective installation (Option 1 above) to manually copy specific files
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

## Session Context & Memory Management

Claude Code sessions have limited context windows, so I've developed patterns to manage both memory and context effectively:

### Context Management Strategies
- **CLAUDE.md** - Persistent directives loaded at session start (doesn't consume conversation context)
- **Agents vs Workers** - Agents consume context even when idle; workers are loaded only when needed
- **Selective Tool Usage** - Some slash commands delegate to the Task tool to avoid loading everything into main context
- **Job Queuing** - The `addjob` system defers work to future sessions, preserving context for current tasks

### Memory Persistence
- **Global Memory** - `~/.claude/CLAUDE.md` persists across all projects and sessions
- **Project Memory** - `.claude/CLAUDE.md` in projects adds project-specific context
- **Session Capture** - Slash commands like `/docs:capture-session` preserve session knowledge for handoffs
- **Learning Extraction** - `/learn` slash command extracts insights from conversations into permanent memory

### Why This Matters
Context is precious in AI systems. By managing it carefully, I can:
- Work on larger, more complex tasks without hitting limits
- Maintain consistent behavior across sessions
- Build up institutional knowledge over time
- Hand off work between sessions or team members effectively

## Directives Compilation

I organize my Claude directives (coding standards, behavioral guidelines, technical patterns) using a compilation system that might be unnecessary with Claude's newer @-mention feature.

### How My Directives System Works

1. **Numbered directive files** in `directives/`:
   - `0010_core_principles.md` - Core behavioral guidelines
   - `0020_prompt_engineering.md` - AI prompt best practices  
   - `0030_engineering_strategies.md` - Technical patterns
   - Files are numbered to control compilation order

2. **Compilation via `rebuild_claude_md.sh`**:
   ```bash
   ./rebuild_claude_md.sh
   ```
   - Concatenates all `.md` files in `directives/` folder
   - Processes them in alphabetical order (hence the numbering)
   - Creates `directives/CLAUDE_global_directives.md`
   - This compiled file is symlinked as `~/.claude/CLAUDE.md`

3. **Why this approach?**
   - Keeps different directive categories organized in separate files
   - Makes it easy to enable/disable specific directives (rename to `.disabled`)
   - Version control tracks changes to individual directive categories
   - Compilation creates a single file that Claude reads at startup

### Note About Claude's @-Mention Feature

**Claude Code now supports @-mentioning files directly**, which might make this compilation approach unnecessary. You could potentially:
- Keep directives in separate files
- @-mention specific directive files when needed
- Avoid the compilation step entirely

I'm still investigating whether @-mentions fully replace the need for a compiled CLAUDE.md. For now, my compilation system works reliably.

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
   - Start with one or two agents/slash commands you'll actually use
   - Test them by copying to `~/.claude/` first
   - Once they work, commit them to your repo
   - Gradually build up your collection

3. **How I Sync Across Machines**
   - I use symlinks from `~/.claude/` to my repo
   - When I update the repo on one machine, I pull on others
   - This keeps all my machines consistent
   - You might prefer a different approach

4. **Ideas for Your Configuration**
   - **Automate what you do repeatedly** - That's what slash commands are for
   - **Create agents for your review process** - Code review, security, docs
   - **Add hooks for your common mistakes** - Prevent errors before they happen
   - **Build your own directives** - Your coding standards, not mine

### Best Practices for Your Configuration

- **Start Small**: Begin with 2-3 agents and slash commands, grow organically
- **Document Everything**: Each component should explain its purpose
- **Version Control**: Commit your customizations for team sharing
- **Test First**: Verify components work before team-wide deployment

## Documentation

### Additional Resources
- **[Architecture Guide](docs/ARCHITECTURE.md)** - Technical design and structure  
- **[Terminal Colors](docs/TERMINAL_COLORS.md)** - Workarounds for Claude Code color rendering
- **[Research & Patterns](resources/)** - Collected learnings and experiments

