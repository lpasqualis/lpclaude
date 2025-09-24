# CLAUDE.md

## What This Is
**This is my personal Claude Code configuration repository.** I use it to:
- Version control my Claude customizations
- Sync my setup across multiple machines
- Share examples of how to organize Claude Code configurations

**This is NOT a framework or product to install.** It's one person's configuration shared as an example. You should create your own configuration with your own preferences.

## How I Use This Repository
I maintain my Claude Code extensions (agents, slash commands, directives, output styles) here and use symlinks to make them available in ~/.claude/ across all my projects.

## Architecture

### Dual .claude System
- **Global** (`~/.claude/`): Symlinked to this repo, available in all projects
- **Local** (`.claude/`): Framework maintenance slash commands only

### Scope Rules
- `commands/`, `agents/`, `output-styles/` → Global via symlinks
- `.claude/commands/`, `.claude/agents/` → Project-local only

## Essential Commands (Shell Commands)

```bash
./setup.sh                        # Create symlinks from ~/.claude/ to this repo
./rebuild_claude_md.sh            # Compile directives into CLAUDE_global_directives.md
/maintenance:update-knowledge-base # Update embedded Claude Code knowledge (quarterly)
```

## Framework Execution Rules

### Hierarchy

**Execution Capabilities by Level:**

1. **Main Claude** (top level - you interacting with user)
   - ✅ Can invoke subagents using the Task tool with `subagent_type: <subagent-name>`
   - ✅ Can invoke workers using Task tool with `subagent_type: 'general-purpose'`
   - ✅ Can execute slash commands

2. **Slash Commands** (when Main Claude runs a command like `/some-command`)
   - ✅ Can invoke subagents using Task tool with `subagent_type: <subagent-name>`
   - ✅ Can invoke workers using Task tool with `subagent_type: 'general-purpose'`
   - ✅ Can execute other slash commands via SlashCommand tool
   - ⚠️ No automatic circular dependency protection - authors must avoid infinite loops

3. **Subagents/Workers** (invoked via Task tool by Main Claude or Slash Commands)
   - ❌ Cannot use Task tool
   - ✅ Can execute slash commands via SlashCommand tool

### Key Constraints
- **Subagents CANNOT have Task tool** - Filtered at framework level
- **Slash Commands CAN use Task** - Up to 10 concurrent Task invocations
- **All Task invocations can be parallel** - From Main Claude or slash commands
- **No recursive delegation** - Tasks and/or subagents can't spawn other Tasks or subagents
- **Subagents only trigger on user input**, never on Claude's output
- **No "proactive" field in YAML** - Use "MUST BE USED PROACTIVELY" in description
- **Agent changes require Claude Code restart** - Agents load at startup only
- **Slash Command changes require Claude Code restart** - Slash commands load at startup only

### Slash Commands
- Slash commands are markdown files with instructions, not executables
- Claude reads the .md file and follows its instructions
- Location: `commands/[namespace/]name.md` (for slash commands)

## Design Principles
- **Discover, don't hardcode** - Find project structure dynamically
- **Test immediately** - No implementation is complete without verification
- **Respect scope** - Global vs local component boundaries

## Quick Reference

### Component Creation
- **Agents**: `agents/name.md` with YAML (name, description, tools - no Task)
- **Slash Commands**: `commands/namespace/name.md` with YAML (allowed-tools including Task)
- **Workers**: `workers/{command}-workers/purpose.md` (pure prompt, no YAML)
- **Output Styles**: `output-styles/name.md` with YAML

### Naming Conventions
- Agents/Slash Commands: `lowercase-hyphenated`
- Namespaces: `/domain:action-target`
- Worker subdirectories: `{command}-workers/`

## Documentation

### Subdirectory Context
- **Workers** (`workers/CLAUDE.md`): Worker template patterns and organization

### Key References  
- **Architecture** (`docs/ARCHITECTURE.md`): Technical design patterns

## Important Notes
- Changes here affect ALL projects using Claude Code
- Test components before global deployment

## Documentation Standards
- **Accuracy** - List only components that exist, verify before documenting
- **Clarity** - Focus on value and real usage, not marketing
- **Completeness** - Include all component types (agents, slash commands, hooks, etc.)
- **Organization** - Group by function, not alphabetically