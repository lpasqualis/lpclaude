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
# For commands: Type the slash command (e.g., /learn, /commit-and-push)
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
- **Invocation**: Slash commands typed by user (e.g., `/learn`)
- **Context**: Full access to current conversation and context
- **Use When**: User needs to trigger specific workflows
- **Examples**: `/commit-and-push`, `/learn`, `/review`

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

## Development Guidelines

### Required YAML Frontmatter Fields
- **Agents & Commands**: Must include `name` and `description`
- **Optional Fields for Agents**: `proactive`, `model`, `color`
- **CRITICAL**: Commands CANNOT have a `model` field - this will cause the command to fail

### File Naming Conventions
| Component | Convention | Example |
|-----------|-----------|---------|
| Agents | lowercase-hyphenated.md | `memory-keeper.md` |
| Commands | lowercase-hyphenated.md | `commit-and-push.md` |
| Directives | descriptive_names.md | `important_instruction_reminders.md` |

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