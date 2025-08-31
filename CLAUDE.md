# CLAUDE.md

This file provides guidance to Claude Code when working in the **Claude Framework Development Workspace**.

## Project Purpose
Central repository where custom agents, commands, directives, and output styles are developed and maintained for global use across all projects.

## Critical Architecture

### Dual .claude Folder System
- **Global** (`~/.claude/`): Symlinked folders accessible in ALL projects
  - `agents/`, `commands/`, `resources/`, `output-styles/` → point to this repo
- **Local** (`.claude/` in this repo): Framework maintenance commands only
  - Contains `/maintenance:update-knowledge-base` and other meta-commands

### Scope Rules
- Files in `commands/`, `agents/`, `output-styles/` = Global (via symlinks)
- Files in `.claude/commands/`, `.claude/agents/` = Project-local
- Optimizers must respect this distinction when creating components

## Essential Commands

```bash
./setup.sh                        # Create symlinks from ~/.claude/ to this repo
./rebuild_claude_md.sh            # Compile directives into CLAUDE_global_directives.md
/maintenance:update-knowledge-base # Update embedded Claude Code knowledge (quarterly)
```

## Framework Execution Rules

### Hierarchy
```
Main Claude → Can use Task → Invoke any subagent
           → Can execute → Slash commands
               └── Commands → Can use Task → Invoke workers (parallel OK!)
                           → Cannot execute other commands
                               └── Workers → Cannot use Task tool
                                           → Cannot execute commands
```

### Key Constraints
- **Subagents CANNOT have Task tool** - Filtered at framework level
- **Commands CAN use Task** for parallel execution (up to 10 concurrent)
- **No recursive delegation** - Tasks can't spawn Tasks
- **Subagents only trigger on user input**, never on Claude's output
- **No "proactive" field in YAML** - Use "MUST BE USED PROACTIVELY" in description
- **Agent changes require Claude Code restart** - Agents load at startup only

### Slash Command Clarity
Slash commands like `/doublecheck` or `/jobs:do` are markdown files containing instructions:
- Location: `.claude/commands/[namespace/][name].md` or `~/.claude/commands/[namespace/][name].md`
- Usage: READ the .md file with Read tool, then FOLLOW its instructions
- NEVER write "execute /command" - commands are not bash executables

## Framework Design Principles
- **Discover, don't hardcode** - Find project structure dynamically
- **Adapt to conventions** - Don't impose fixed patterns
- **Complete tool groups** - Grant logical permission sets (Read+Write+Edit)
- **Test immediately** - No implementation is complete without verification

## Quick Reference

### Creating Components
- **Agents**: `agents/name.md` with YAML (name, description, tools)
- **Commands**: `commands/namespace/name.md` with YAML (allowed-tools)
- **Worker Templates**: `workers/name.md` (pure prompt, no YAML)
- **Output Styles**: `output-styles/name.md` with YAML

### Tool Permission Groups
- **Read-only**: `Read, LS, Glob, Grep`
- **File modification**: `Read, Write, Edit, MultiEdit, LS, Glob, Grep`
- **Complex workflows**: Include `Task` for commands (never for agents)

### Naming Conventions
- Agents/Commands: `lowercase-hyphenated`
- Namespaces: `/domain:action-target`
- Worker templates: `{command}-{purpose}.md`

## Additional Documentation

### Module-Specific Context
- **Workers Context** (`workers/CLAUDE.md`): Worker template organization and patterns

### Reference Guides
- **Getting Started** (`docs/QUICK_START.md`): Environment setup and first steps
- **Component Reference** (`docs/REFERENCE.md`): Catalog of existing components
- **Development Guide** (`docs/DEVELOPMENT.md`): Creating new components
- **Architecture** (`docs/ARCHITECTURE.md`): Complex workflow design
- **Advanced Patterns** (`docs/ADVANCED_PATTERNS.md`): Parallel processing techniques
- **Troubleshooting** (`docs/TROUBLESHOOTING.md`): Common issues and solutions
- **Terminal Colors** (`docs/TERMINAL_COLORS.md`): ANSI color handling in Claude Code

### Research & Best Practices
- `resources/slash_commands_best_practices_research.md`: Command design patterns
- `resources/subagent_invocation_research.md`: Agent creation guidelines
- `resources/commands_and_agents.md`: Framework internals

## Project-Specific Notes

- This repository IS the global configuration (via symlinks)
- Changes here affect ALL your projects using Claude Code
- Test in isolation before global deployment