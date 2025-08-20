# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Purpose

This is the **Claude Framework Development Workspace** - a central repository where custom agents, commands, directives, and output styles are developed and maintained for global use across all projects. This repository serves as the source of truth for your personal Claude Code customizations.

## Critical Architecture: Dual .claude Folder System

This project uses a sophisticated dual-folder architecture for Claude configurations:

### 1. Global Configuration (via Symlinks)
- **Location**: `~/.claude/` (your home directory)
- **Purpose**: Makes agents, commands, and output styles available globally across ALL projects
- **How it works**: The `setup.sh` script creates symlinks from `~/.claude/` to this repository's folders:
  - `~/.claude/agents/` → `{this-repo}/agents/`
  - `~/.claude/commands/` → `{this-repo}/commands/`
  - `~/.claude/resources/` → `{this-repo}/resources/`
  - `~/.claude/output-styles/` → `{this-repo}/output-styles/`
  - `~/.claude/CLAUDE.md` → `{this-repo}/CLAUDE_global_directives.md`
- **Result**: Any project you work on can use these agents, commands, and output styles

### 2. Project-Local Configuration (Maintenance Commands)
- **Location**: `.claude/` (in THIS repository only)
- **Purpose**: Contains specialized maintenance commands for developing the framework itself
- **Contents**:
  - `.claude/commands/maintenance/` - Framework maintenance commands
  - `.claude/settings.local.json` - Local tool permissions (gitignored)
- **Special commands**: Available ONLY when working in this framework project:
  - `/maintenance:update-knowledge-base` - Updates embedded Claude Code knowledge
- **Why separate**: These meta-commands are for framework development, not general use

### Understanding the Flow
```
Your Computer
├── ~/.claude/                    # Global Claude config (symlinks)
│   ├── agents/ → this-repo/agents/
│   ├── commands/ → this-repo/commands/
│   ├── resources/ → this-repo/resources/
│   └── output-styles/ → this-repo/output-styles/
│
├── this-repository/               # Framework development workspace
│   ├── agents/                   # Source of global agents
│   ├── commands/                  # Source of global commands
│   ├── resources/                 # Source of global resources
│   ├── output-styles/             # Source of global output styles
│   ├── .claude/                   # LOCAL maintenance commands
│   │   └── commands/maintenance/  # Framework-only commands
│   └── setup.sh                   # Creates the symlinks
│
└── other-projects/                # Your other projects
    └── (uses global ~/.claude/)  # Access to all agents/commands/styles
```

### Critical Understanding: Global vs Local Scope in this Repository

**IMPORTANT**: Since this repository's `commands/`, `agents/`, and `output-styles/` folders ARE the global folders (via symlinks):
- Files in `commands/`, `agents/`, and `output-styles/` = Global scope (accessible everywhere via `~/.claude/`)
- Files in `.claude/commands/` and `.claude/agents/` = Project-local scope (only in this repo)

This distinction is crucial for:
1. **Optimizer agents**: They should only look in `.claude/` (project-local) and `~/.claude/` (global)
2. **Companion agents**: Must be created in the same scope as their parent command
3. **Slash command references**: Must specify correct paths for reading command files

## Bash Commands

**ALWAYS use these commands when working in this repository:**

```bash
# Initial setup - creates symlinks from ~/.claude/ to this repository
./setup.sh

# Build directives - compiles all directives into CLAUDE_global_directives.md
./rebuild_claude_md.sh

# Test agents/commands after modification
# For agents: Use Task tool with subagent_type
# For commands: Type the slash command (e.g., /memory:learn, /git:commit-and-push)

# Framework maintenance (only available in THIS project)
/maintenance:update-knowledge-base
```

## Critical Framework Execution Rules

### Claude Code Execution Hierarchy and Constraints

**IMPORTANT**: These are fundamental architectural constraints of Claude Code that must be respected when designing commands and agents:

```
Main Claude Session
    ├── Can use Task → Invoke any subagent
    ├── Can execute → Slash commands
    └── Slash Commands (run in main session)
            ├── Can use Task → Invoke worker subagents (parallel OK!)
            ├── Cannot → Execute other slash commands directly
            └── Worker Subagents (isolated context)
                    ├── Can use → Their allowed tools
                    ├── Cannot use → Task tool (no recursive delegation)
                    └── Cannot → Execute slash commands
```

### Valid Patterns ✅
1. **Commands using Task to invoke multiple worker subagents in parallel** - This is powerful and should be used
2. **Main Claude using Task to invoke any subagent** - Standard delegation pattern
3. **Commands creating cmd-* worker agents for parallel execution** - Excellent for performance
4. **Commands reading other command files for reference** - Use direct file reading, not execution

### Invalid Patterns ❌ (Will Not Work)
1. **Subagents with Task tool attempting recursive delegation** - Subagents cannot invoke other subagents
2. **Subagents trying to execute slash commands** - They run in isolated contexts without command access
3. **Commands trying to directly execute other slash commands** - Commands cannot invoke other commands
4. **The slash-command-executor agent concept** - Fundamentally flawed as subagents can't execute commands

### Key Rules for Framework Development
- **Subagents MUST NOT have Task tool** - They cannot use it anyway (no recursive delegation)
- **Commands CAN and SHOULD use Task** - For invoking worker subagents, including parallel execution
- **Worker pattern is valid** - Commands orchestrate, workers execute, results return to command
- **Parallel execution from commands works** - Up to 10 concurrent subagent invocations

## Workflow Instructions

### Creating a New Agent
1. Create a new `.md` file in `agents/` directory
2. Use lowercase-hyphenated naming: `agent-name.md`
3. Include YAML frontmatter with required fields:
   ```yaml
   ---
   name: agent-name
   description: Clear, action-oriented description for automatic delegation
   proactive: true/false  # Optional: whether agent should be used proactively
   tools: Read, LS, Glob, Grep  # NO Task tool for subagents!
   ---
   ```
4. **CRITICAL**: Do NOT include Task in tools list (subagents cannot delegate)
5. Test immediately using Task tool with the agent name

### Creating a New Command
1. Create a new `.md` file in `commands/` directory
2. Use lowercase-hyphenated naming: `command-name.md`
3. Include YAML frontmatter with required fields:
   ```yaml
   ---
   name: /command-name
   description: What this command does
   allowed-tools: Read, Write, Edit, LS, Glob, Grep, Task  # Task is OK for commands!
   # WARNING: The 'model' field works but often causes token limit errors
   # Many models have lower max_tokens than Claude Code's default (e.g., Opus: 4096 vs 21333 requested)
   # Only use if you know the model's token limits are compatible
   # Check current models: https://docs.anthropic.com/en/docs/about-claude/models/overview
   # Check deprecations: https://docs.anthropic.com/en/docs/about-claude/model-deprecations
   ---
   ```
4. Commands CAN use Task to invoke worker subagents (including parallel execution)
5. Commands CANNOT directly execute other slash commands
6. Test immediately by invoking the slash command

### Creating a New Output Style
1. Create a new `.md` file in `output-styles/` directory
2. Use descriptive naming: `style-name.md`
3. Include YAML frontmatter with required fields:
   ```yaml
   ---
   name: Style Name
   description: Brief description of what this style does
   ---
   ```
4. Add custom system prompt instructions below the frontmatter
5. Test by using `/output-style` command to activate it

### Testing and Validation
- **CRITICAL**: No implementation is complete without passing tests
- After any modification, immediately test the component
- Agents: Invoke via Task tool and verify expected behavior
- Commands: Execute the slash command and verify output
- Run `./rebuild_claude_md.sh` after modifying directives

## Project Overview

This repository contains a collection of Claude Code subagents, commands, directives, and output styles designed to enhance AI-assisted development workflows. It serves as both a framework and a shareable configuration that can be symlinked into the Claude home directory (~/.claude).

## Architecture & Components

### Component Types and Their Purposes

#### Subagents (`agents/`)
- **Purpose**: Specialized AI workers that operate in isolated contexts
- **Invocation**: Via Task tool with `subagent_type` parameter
- **Context**: Receive specific prompts, return results to main agent
- **Use When**: Need focused, specialized processing without full context
- **Examples**: `memory-keeper`, `hack-spotter`, `claude-md-optimizer`

#### Commands (`commands/`)
- **Purpose**: User-invoked operations that execute in main Claude session
- **Invocation**: Slash commands typed by user (e.g., `/memory:learn`)
- **Context**: Full access to current conversation and context
- **Use When**: User needs to trigger specific workflows
- **Examples**: `/git:commit-and-push`, `/memory:learn`, `/subagents:review-ecosystem`

#### Directives (`directives/`)
- **Purpose**: Modify Claude's behavior and provide persistent instructions
- **Invocation**: Automatically loaded based on context
- **Context**: Applied throughout the session
- **Use When**: Need to establish behavioral rules or guidelines
- **Note**: Only `.md` files are tracked; `.local.md` files are ignored

#### Output Styles (`output-styles/`)
- **Purpose**: Modify Claude's system prompt for specialized use cases and domains
- **Invocation**: Via `/output-style` command or settings
- **Context**: Changes Claude's overall behavior and communication style
- **Use When**: Need domain-specific expertise or communication patterns
- **Examples**: `claude-agentic-framework` for framework development

### Directory Structure
```
agent/
├── agents/           # Subagent definitions with YAML frontmatter
├── commands/         # Slash command definitions  
├── directives/       # Behavioral modification files
├── output-styles/    # Output style definitions for modifying Claude's behavior
├── resources/        # Documentation and reference materials
├── setup.sh          # Creates symlinks to ~/.claude/
└── rebuild_claude_md.sh          # Compiles directives into CLAUDE_global_directives.md
```

## Reference Documentation

### Critical Resources for Framework Development

The following resources contain comprehensive best practices and technical details for working with the Claude agent framework:

#### 1. Slash Commands Best Practices
**Location**: `resources/slash_commands_best_practices_research.md`

**Contains**:
- Single Responsibility Principle for commands
- Predictability and checklist-driven execution patterns
- Context management with CLAUDE.md integration
- Workflows vs. Tools dichotomy and trade-offs
- Command orchestration patterns (sequential and parallel)
- Security and governance best practices
- Common anti-patterns to avoid

**Reference When**:
- Creating new slash commands
- Optimizing command performance and reliability
- Designing command workflows
- Implementing security measures

#### 2. Subagent Architecture and Invocation
**Location**: `resources/subagent_invocation_research.md`

**Contains**:
- The subagent paradigm and contextual isolation principles
- Invocation mechanics (implicit vs. explicit)
- Designing agents for proactive invocation
- Multi-agent architectures and orchestration patterns
- The subagent ecosystem and interaction patterns
- Performance considerations and best practices

**Reference When**:
- Creating new subagents
- Designing multi-agent workflows
- Troubleshooting invocation issues
- Optimizing agent performance
- Teaching subagent concepts to team members

#### 3. Technical Deep Dive
**Location**: `resources/commands_and_agents.md`

**Contains**:
- Detailed subagent vs. slash command distinctions
- Parallel execution mechanics and system constraints
- Advanced orchestration strategies and patterns
- Blueprint for creating high-quality subagents
- Technical architecture decisions and rationales

**Reference When**:
- Understanding technical implementation details
- Planning complex multi-component solutions
- Resolving architectural questions
- Conducting technical reviews

### Using These Resources
These documents should be consulted regularly during development to ensure consistency with established patterns and best practices. They contain research-backed approaches that have been validated through practical implementation.

## Optimizer Maintenance

### Simplified Optimizer Architecture
The optimizer subagents (`command-optimizer` and `subagent-optimizer`) use embedded best practices rather than fetching documentation at runtime. This design choice provides:
- **Faster execution**: No network calls during optimization
- **Reliability**: No dependency on external services
- **Consistency**: Predictable behavior across runs

### Critical: How Optimizers Should Work (Updated for Constraints)

**IMPORTANT UPDATE**: Optimizer agents themselves are subagents and therefore CANNOT have Task tool. This means:

1. **Optimizers cannot delegate to other agents** - They must do all work directly
2. **Optimizers can create companion worker agents** - But only for commands to use (commands CAN use Task)
3. **Slash command references must be converted to file reading** - Since subagents cannot execute commands

When optimizers encounter references to slash commands:
1. **Convert to file reading pattern**: Replace "execute /command" with "read ~/.claude/commands/[path].md"
2. **Maintain scope consistency**: Create companion agents in same scope as parent command
3. **Ensure workers have no Task tool**: Created worker agents must not attempt delegation

**Architecture Note**: The command-optimizer and subagent-optimizer themselves need fixing:
- Remove Task tool from their allowed tools (they're subagents, can't delegate)
- Keep logic for creating worker agents (valid for commands to use)
- Update slash command handling to use file reading only

### Knowledge Base Updates
To keep optimizer knowledge current with Claude Code updates:
- **Command**: `/maintenance:update-knowledge-base`
- **Frequency**: Run quarterly or after major Claude Code releases
- **Purpose**: Fetches latest documentation and identifies components needing updates
- **Scope**: Updates both optimizers and resource documentation

### Maintenance Schedule
- **Quarterly**: Run `/maintenance:update-knowledge-base` to check for updates
- **After Claude Code releases**: Check changelog and run maintenance command
- **Manual trigger**: Use `force` argument to skip time-based checks

The knowledge base manifest (`resources/knowledge-base-manifest.json`) tracks all components with embedded Claude Code knowledge and their update status.

## Session Learnings (2025-08-07)

### Tool Permission Architecture
**Critical Pattern**: Tool permissions must be granted in complete logical groups to prevent runtime failures:
- **Read-only workflows**: `Read, LS, Glob, Grep`
- **File modification workflows**: `Read, Write, Edit, MultiEdit, LS, Glob, Grep`
- **Complex workflows**: All tools including Task

**Anti-Pattern**: Never grant partial tool capabilities (e.g., `Write` without `Edit`, or `Edit` without `Write`). This creates permission gaps that cause commands to fail silently or prompt users for additional permissions.

### Circular Dependency Prevention
**Critical Pattern**: Commands must never reference their own optimization agents to prevent infinite loops.
- **Problem**: Using `@command-optimizer` pattern creates recursive invocation chains
- **Solution**: Create dedicated `cmd-*` validation subagents with `proactive: false`
- **Implementation**: These subagents perform focused validation without triggering optimization loops

### Namespaced Command Structure
**Pattern**: Commands with colons require specific directory organization:
- **Format**: `/namespace:command`
- **Directory Structure**: Create `commands/namespace/command.md`
- **Implementation**: The colon translates to a directory path where the namespace becomes a subdirectory

### Performance Optimization Patterns
**Parallel Execution Architecture**: Create `cmd-[name]-[function]` subagents for parallel operations within commands:
- **Valid Pattern**: Commands use Task to invoke multiple workers in parallel ✅
- **Context**: Worker subagents run without conversation context using lighter models (haiku)
- **Capacity**: Enable up to 10 parallel executions
- **Design**: Workers should be independent and focused on result aggregation
- **Critical Rule**: Worker subagents MUST NOT have Task tool (no recursive delegation)

**Idempotent Optimization Pattern**: Follow "analyze first, act only if necessary" approach:
- **Process**: Check if changes are actually required before using Edit/Write tools
- **Benefit**: Prevents unnecessary file changes and version control noise

### Documentation Maintenance Patterns
**Audit Pattern**: Regular documentation audits needed to catch undocumented components:
- **Issue**: New cmd-* agents and commands often created without updating documentation
- **Solution**: Structured documentation formats enable easier auditing and gap detection
- **Impact**: Prevents knowledge gaps and reduces duplicate development efforts

## Development Guidelines

### VS Code Integration Resources

**Date Added**: 2025-08-15

#### Theme Color Customization
When working with VS Code workspace customization commands (like `/vs:tint-workspace`), refer to the official documentation for available color properties:
- **Theme Color Reference**: https://code.visualstudio.com/api/references/theme-color
- Lists all available `workbench.colorCustomizations` properties
- Organized by UI component (Activity Bar, Status Bar, Sidebar, etc.)
- Includes descriptions of what each color property affects

### Command Naming and Organization Philosophy

**Date Added**: 2025-08-07 - Emerged from command normalization session

#### Core Principles
- **Namespace by functional domain/scope**: Folders represent the area of work, not the action
- **Clear action-oriented names**: Commands within namespaces start with action verbs  
- **Domain-focused organization**: Group by what you're working with, not what you're doing
- **Logical scope separation**: Each namespace represents a distinct domain of functionality

#### Established Functional Domains
- **Implementation Plans** (`implan:*`): Commands for managing implementation plans and project execution
- **Documentation** (`docs:*`): Commands for capturing and managing various types of documentation  
- **Git Operations** (`git:*`): Version control and repository management
- **Memory Management** (`memory:*`): Commands for learning capture and long-term memory management
- **Subagent Management** (`subagents:*`): Commands for managing and reviewing subagents
- **Command Management** (`commands:*`): Commands for managing the Claude command system itself
- **VS Code Integration** (`vs:*`): Commands for VS Code workspace customization and tooling

#### Naming Conventions
- Use lowercase-hyphenated format for multi-word command names
- Start command names with clear action verbs (create, execute, capture, review, etc.)
- Namespace structure: `/domain:action-target` (e.g., `/implan:create`, `/subagents:review-ecosystem`)
- Avoid action-based folder names (like "analyze") - focus on the domain/scope instead

#### Anti-Patterns to Avoid
- Don't use folders named after actions (analyze, create, etc.) - they should represent domains
- Don't put development tools in generic "dev" folders - use specific domains like "commands"
- Avoid generic or ambiguous command names that don't clearly indicate their purpose

### Required YAML Frontmatter Fields
- **Agents & Commands**: Must include `name` and `description`
- **Optional Fields for Agents**: `proactive`, `model`, `color`
- **WARNING**: The `model` field in commands works but often causes token limit errors (e.g., Opus 3 only supports 4096 tokens while Claude Code requests 21333)
- **Model Selection**: Always verify model compatibility at:
  - Current models: https://docs.anthropic.com/en/docs/about-claude/models/overview
  - Deprecation schedule: https://docs.anthropic.com/en/docs/about-claude/model-deprecations

### File Naming Conventions
| Component | Convention | Example |
|-----------|-----------|---------|
| Agents | lowercase-hyphenated.md | `memory-keeper.md` |
| Command-Specific Agents | cmd-{command}-{purpose}.md | `cmd-commit-and-push-analyzer.md` |
| Commands | lowercase-hyphenated.md | `commit-and-push.md` |
| Directives | descriptive_names.md | `important_instruction_reminders.md` |

### Command-Specific Agent Pattern (cmd-*)
The repository uses specialized `cmd-*` agents for command-specific processing:
- **Purpose**: Focused, specialized processing for specific commands
- **Execution**: Designed for parallel execution to improve performance
- **Model Selection**: Often use `haiku` for speed in parallel operations
- **Integration**: Called by main commands to handle specific analysis tasks

### Parallel Execution Patterns
Some commands leverage parallel execution for improved performance:
- **Batch Processing**: Process up to 10 agents simultaneously (system limit)
- **Task Distribution**: Break complex analysis into parallel tasks
- **Result Aggregation**: Combine parallel results into unified reports
- **Example**: `review-subagent-ecosystem` uses parallel analysis for large agent sets

### Best Practices
1. **Clear Descriptions**: Use action-oriented descriptions that enable automatic delegation
2. **Immediate Testing**: Test changes immediately after modification
3. **No Hardcoding**: Never hardcode specific cases into generic code
4. **Follow Patterns**: Examine existing components before creating new ones
5. **Version Control**: Only modify files tracked in the repository

### Documentation Rules
**CRITICAL**: Only document repository-tracked aspects:
- ✅ Document: Files in `agents/`, `commands/`, tracked `directives/*.md`
- ❌ Skip: `archive/` directory, `*.local.md` files, `.gitignore`'d content
- Use `.gitignore` and `.gitkeep` to determine what's part of the repository

## Critical Reminders

**IMPORTANT BEHAVIORAL CONSTRAINTS:**

1. **Do what has been asked; nothing more, nothing less**
2. **NEVER create files unless absolutely necessary for achieving your goal**
3. **ALWAYS prefer editing an existing file to creating a new one**
4. **NEVER proactively create documentation files (*.md) or README files unless explicitly requested**
5. **No implementation is complete unless tested and tests pass**
6. **Treat all warnings as errors - clean output required**
7. **Never use emojis in any output, messages, documentation, or code**

## Setup and Installation

The setup process creates symlinks from `~/.claude/` to this repository's folders, allowing Claude to discover and use these configurations globally:

```bash
# Run from repository root
./setup.sh
```

This enables:
- Global access to all agents via Task tool
- Slash commands available in any Claude session
- Directives automatically applied based on context