# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

This project is a Claude Code framework of agents, commands and directives.

## Bash Commands

**ALWAYS use these commands when working in this repository:**

```bash
# Initial setup - creates symlinks to ~/.claude/
./setup.sh

# Build directives - compiles all directives into CLAUDE_global_directives.md
./build.sh

# Test agents/commands after modification
# For agents: Use Task tool with subagent_type
# For commands: Type the slash command (e.g., /memory:learn, /git:commit-and-push)
```

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
   ---
   ```
4. Test immediately using Task tool with the agent name

### Creating a New Command
1. Create a new `.md` file in `commands/` directory
2. Use lowercase-hyphenated naming: `command-name.md`
3. Include YAML frontmatter with required fields:
   ```yaml
   ---
   name: /command-name
   description: What this command does
   # CRITICAL: Do NOT include 'model' field - it will cause command failure
   ---
   ```
4. Test immediately by invoking the slash command

### Testing and Validation
- **CRITICAL**: No implementation is complete without passing tests
- After any modification, immediately test the component
- Agents: Invoke via Task tool and verify expected behavior
- Commands: Execute the slash command and verify output
- Run `./build.sh` after modifying directives

## Project Overview

This repository contains a collection of Claude Code subagents, commands, and directives designed to enhance AI-assisted development workflows. It serves as both a framework and a shareable configuration that can be symlinked into the Claude home directory (~/.claude).

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

### Directory Structure
```
agent/
├── agents/           # Subagent definitions with YAML frontmatter
├── commands/         # Slash command definitions  
├── directives/       # Behavioral modification files
├── resources/        # Documentation and reference materials
├── setup.sh          # Creates symlinks to ~/.claude/
└── build.sh          # Compiles directives into CLAUDE_global_directives.md
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
- **Context**: These subagents run without conversation context using lighter models (haiku)
- **Capacity**: Enable up to 10 parallel executions
- **Design**: Should be independent and focused on result aggregation

**Idempotent Optimization Pattern**: Follow "analyze first, act only if necessary" approach:
- **Process**: Check if changes are actually required before using Edit/Write tools
- **Benefit**: Prevents unnecessary file changes and version control noise

### Documentation Maintenance Patterns
**Audit Pattern**: Regular documentation audits needed to catch undocumented components:
- **Issue**: New cmd-* agents and commands often created without updating documentation
- **Solution**: Structured documentation formats enable easier auditing and gap detection
- **Impact**: Prevents knowledge gaps and reduces duplicate development efforts

## Development Guidelines

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
- **CRITICAL**: Commands CANNOT have a `model` field - this will cause the command to fail

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