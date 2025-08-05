# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

This project is a Claude Code framework of agents, commands and directives.

## Project Overview

This repository contains a collection of Claude Code subagents, commands, and directives designed to enhance AI-assisted development workflows. It serves as both a framework and a shareable configuration that can be symlinked into the Claude home directory (~/.claude).

## Key Architecture Concepts

### Subagents vs Commands
- **Subagents** (in `agents/`): Markdown files that define specialized AI workers that operate in isolated contexts. They are invoked via the Task tool and return results to the main agent.
- **Commands** (in `commands/`): User-invoked slash commands (e.g., `/learn`, `/commit-and-push`) that execute specific workflows directly in the main Claude session.

### Directory Structure
- `agents/`: Contains subagent definition files (.md) with YAML frontmatter defining their capabilities
- `commands/`: Contains command definition files (.md) for user-invoked operations
- `directives/`: Contains Claude directive files that modify Claude's behavior
- `resources/`: Contains documentation and reference materials

## Setup and Installation

Use the provided setup script to create symlinks:
```bash
./setup.sh
```

This creates symlinks from ~/.claude/ to the repository folders, allowing Claude to discover and use these configurations globally.

## Development Guidelines

### When modifying agents or commands:
1. Follow the existing naming convention: lowercase with hyphens (e.g., `memory-keeper.md`)
2. Ensure YAML frontmatter includes required fields: `name` and `description`
3. Use clear, action-oriented descriptions that enable automatic delegation
4. Test changes by invoking the agent/command after modification

### Documentation Rules
- IMPORTANT: ONLY document aspects of this project that are tracked in the repository. Use .gitignore / .gitkeep to determine what is part of the repo
  - Do not document the `archive/` directory or any ignored files
  - Pay particular attention to document only `directives/` that are included in the repo. Do not document any *.local.md files.

### File Naming Conventions
- Agents: `agent-name.md` (lowercase, hyphenated)
- Commands: `command-name.md` (lowercase, hyphenated)
- Directives: `*.md` descriptive names with underscores
