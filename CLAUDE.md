# CLAUDE.md

This file provides guidance to Claude Code when working in the **Claude Framework Development Workspace**.

## Table of Contents
- [CLAUDE.md](#claudemd)
  - [Table of Contents](#table-of-contents)
  - [Project Purpose](#project-purpose)
  - [Critical Architecture](#critical-architecture)
    - [Dual .claude Folder System](#dual-claude-folder-system)
    - [Scope Rules](#scope-rules)
  - [Essential Commands](#essential-commands)
  - [Framework Execution Rules](#framework-execution-rules)
    - [Hierarchy](#hierarchy)
    - [Key Constraints](#key-constraints)
    - [Task Template Pattern](#task-template-pattern)
    - [Slash Command Clarity](#slash-command-clarity)
  - [Framework Design Principles](#framework-design-principles)
  - [Quick Reference](#quick-reference)
    - [Creating Components](#creating-components)
    - [Tool Permission Groups](#tool-permission-groups)
    - [Naming Conventions](#naming-conventions)
  - [Documentation](#documentation)
    - [Quick References](#quick-references)
    - [Development Resources](#development-resources)
    - [Research \& Best Practices (`resources/`)](#research--best-practices-resources)
  - [Claude Code Terminal Color Handling](#claude-code-terminal-color-handling)
    - [Working Color Escape Sequences](#working-color-escape-sequences)
    - [Non-Working Patterns](#non-working-patterns)
    - [Best Practices for Statusline Scripts](#best-practices-for-statusline-scripts)
  - [Project-Specific Notes](#project-specific-notes)

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

### Task Template Pattern
- Create templates in `tasks/` directory (pure prompts, no YAML)
- Load: `Read('tasks/template.md')`
- Execute: `Task(subagent_type: 'general-purpose', prompt: template + context)`

### Slash Command Clarity
**Slash Command Clarity**: Slash commands like /doublecheck or /jobs:do are NOT bash commands - they are markdown files containing instructions and they can have an optional namespace (for example, /doublecheck doesn't have a namespace, and /jobs:do name space is "jobs")
- Location with namespace: `.claude/commands/[namespace]/[name].md` or `~/.claude/commands/[namespace]/[name].md`  
- Location without namespace: `.claude/commands/[name].md` or `~/.claude/commands/[name].md`  

- Usage: First READ the .md file with Read tool, then FOLLOW its written instructions exactly
- NEVER write "execute /command" - instead write "Read the instructions from ~/.claude/commands/[path]/[name].md and follow them"

## Framework Design Principles
- **Discover, don't hardcode** - Find project structure dynamically
- **Adapt to conventions** - Don't impose fixed patterns
- **Complete tool groups** - Grant logical permission sets (Read+Write+Edit)
- **Test immediately** - No implementation is complete without verification

## Quick Reference

### Creating Components
- **Agents**: `agents/name.md` with YAML (name, description, tools)
  - **IMPORTANT**: Agent changes require Claude Code restart - agents are loaded at launch, not dynamically reloaded
- **Commands**: `commands/namespace/name.md` with YAML (name, description, allowed-tools)
- **Task Templates**: `tasks/name.md` (pure prompt, no YAML)
- **Output Styles**: `output-styles/name.md` with YAML

### Agent Development Workflow
- **Testing agent changes**: After modifying an agent file, you MUST exit and restart Claude Code for changes to take effect
- **Agent loading**: Agents are loaded once at Claude Code startup, not on-demand
- **Verification**: Use `/agents` command after restart to confirm agent is loaded with new changes

### Tool Permission Groups
- **Read-only**: `Read, LS, Glob, Grep`
- **File modification**: `Read, Write, Edit, MultiEdit, LS, Glob, Grep`
- **Complex workflows**: Include `Task` for commands (never for agents)

### Naming Conventions
- Agents/Commands: `lowercase-hyphenated`
- Namespaces: `/domain:action-target`
- Task templates: `{command}-{purpose}.md`

## Documentation

> **Note**: Detailed documentation is maintained separately. Consult these when needed:

### Quick References
- **Getting Started** (`docs/QUICK_START.md`): When setting up new environments
- **Component Reference** (`docs/REFERENCE.md`): When looking for existing components
- **Troubleshooting** (`docs/TROUBLESHOOTING.md`): When encountering framework issues

### Development Resources
- **Development Guide** (`docs/DEVELOPMENT.md`): When creating new components
- **Architecture** (`docs/ARCHITECTURE.md`): When designing complex workflows
- **Advanced Patterns** (`docs/ADVANCED_PATTERNS.md`): When implementing parallel processing
- **Migration Guide** (`docs/MIGRATION_GUIDE.md`): When upgrading from legacy patterns

### Research & Best Practices (`resources/`)
- `slash_commands_best_practices_research.md`: When designing commands
- `subagent_invocation_research.md`: When creating agents
- `commands_and_agents.md`: When understanding framework internals

## Claude Code Terminal Color Handling

### Working Color Escape Sequences
Claude Code's terminal properly renders ANSI colors when using these patterns:

1. **Combined escape sequences** - Put background and foreground in ONE escape:
   - ✅ `printf '\e[42;30m text '` (green bg, black fg)
   - ✅ `printf '\e[1;42;30m text '` (bold, green bg, black fg)

2. **Integer format specifiers** - Use `%d` for color codes:
   - ✅ `printf '\e[%d;%dm text ' "$bg" "$fg"`
   - ❌ `printf '\e[%s;%sm text ' "$bg" "$fg"` (may not render correctly)

3. **Standard 8/16 colors** - Use numeric color codes:
   - ✅ `30-37` (foreground), `40-47` (background), `90-97` (bright foreground)
   - ❌ Truecolor/24-bit RGB like `38;2;R;G;B` (not supported)

### Non-Working Patterns
These patterns may display incorrectly or show literal characters:

1. **Separate escape sequences**:
   - ❌ `printf '\e[42m\e[30m text '` (may show as arrows or broken colors)
   
2. **Truecolor sequences**:
   - ❌ `printf '\e[38;2;0;0;0m text '` (24-bit RGB not supported)

3. **String format with color codes**:
   - ❌ Using `%s` format when color codes need integer formatting

### Best Practices for Statusline Scripts
- Combine all SGR parameters in one escape sequence
- Use `%d` format specifier for numeric color codes
- Stick to standard 8/16 color palette
- Test in Claude Code environment, not just external terminal

## Project-Specific Notes

- This repository IS the global configuration (via symlinks)
- Changes here affect ALL your projects using Claude Code
- Test in isolation before global deployment