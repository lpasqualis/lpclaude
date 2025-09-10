# CLAUDE.md

## Project Purpose
Central repository for Claude Code extensions (agents, commands, directives, output styles) that are symlinked globally to ~/.claude/ for use across all projects.

## Architecture

### Dual .claude System
- **Global** (`~/.claude/`): Symlinked to this repo, available in all projects
- **Local** (`.claude/`): Framework maintenance commands only

### Scope Rules
- `commands/`, `agents/`, `output-styles/` → Global via symlinks
- `.claude/commands/`, `.claude/agents/` → Project-local only

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

### Slash Commands
- Commands are markdown files with instructions, not executables
- Claude reads the .md file and follows its instructions
- Location: `commands/[namespace/]name.md`

## Design Principles
- **Discover, don't hardcode** - Find project structure dynamically
- **Test immediately** - No implementation is complete without verification
- **Respect scope** - Global vs local component boundaries

## Quick Reference

### Component Creation
- **Agents**: `agents/name.md` with YAML (name, description, tools - no Task)
- **Commands**: `commands/namespace/name.md` with YAML (allowed-tools including Task)
- **Workers**: `workers/{command}-workers/purpose.md` (pure prompt, no YAML)
- **Output Styles**: `output-styles/name.md` with YAML

### Naming Conventions
- Agents/Commands: `lowercase-hyphenated`
- Namespaces: `/domain:action-target`
- Worker subdirectories: `{command}-workers/`

## Documentation

### Subdirectory Context
- **Workers** (`workers/CLAUDE.md`): Worker template patterns and organization

### Key References
- **Quick Start** (`docs/QUICK_START.md`): Setup and first steps
- **Component Reference** (`docs/REFERENCE.md`): Complete component catalog
- **Development** (`docs/DEVELOPMENT.md`): Creating new components
- **Troubleshooting** (`docs/TROUBLESHOOTING.md`): Common issues and solutions

## Important Notes
- Changes here affect ALL projects using Claude Code
- Test components before global deployment

## Documentation Standards
- **Accuracy** - List only components that exist, verify before documenting
- **Clarity** - Focus on value and real usage, not marketing
- **Completeness** - Include all component types (agents, commands, hooks, etc.)
- **Organization** - Group by function, not alphabetically