# Development Guide

## Creating New Components - The Smart Way

**IMPORTANT: The framework includes powerful tools to create and optimize its own components. Use them!**

### Creating a New Agent (Recommended Approach)

**Use Claude's built-in agent creator:**
```bash
# Simply type:
/agents

# This interactive command will:
# - Guide you through defining the agent's purpose
# - Create properly formatted YAML frontmatter
# - Set appropriate model and other settings
# - Place the agent in the correct location
# - Ensure best practices from the start
```

**After creation, optimize automatically:**
```bash
# Just ask Claude:
"Please optimize the agent I just created"
# or
"Optimize agents/my-new-agent.md"

# This triggers the subagent-optimizer which will:
# - Refine the description for better auto-invocation
# - Optimize model selection (haiku/sonnet/opus)
# - Add semantic colors
# - Ensure automatic invocation triggers are appropriate
# - Apply all current best practices
```

### Creating a New Command (Recommended Approach)

**Use the framework's command creator:**
```bash
# Simply type:
/commands:create

# This interactive command will:
# - Help you choose the right namespace
# - Define requirements and functionality
# - Set appropriate tool permissions (Principle of Least Privilege)
# - Create proper YAML frontmatter
# - Generate the command with best practices built-in
```

**After creation, optimize automatically:**
```bash
# Just ask Claude:
"Please optimize the command I just created"
# or
"Optimize commands/namespace/my-command.md"

# This triggers the command-optimizer which will:
# - Audit tool permissions for security
# - Improve argument hints
# - Ensure proper placeholder usage
# - Check against latest documentation
# - Apply idempotent optimizations
```

### Manual Creation (If Needed)

While the automated tools above are recommended, you can still create components manually:

#### Manual Agent Creation
1. Create file in `agents/` directory
2. Add YAML frontmatter:
```yaml
---
name: my-new-agent
description: Clear, action-oriented description. MUST BE USED PROACTIVELY when [conditions].
model: sonnet    # Optional: haiku, sonnet, or opus
color: blue      # Optional
---
```
3. Write the agent prompt
4. **Important**: Ask Claude to optimize it!

#### Manual Command Creation
1. Create file in appropriate namespace under `commands/`
2. Add YAML frontmatter:
```yaml
---
name: /namespace:my-command
description: What this command does
argument-hint: "[optional-arg]"
allowed-tools: Read, Write, Edit, LS, Glob, Grep
# WARNING: Model field works but check token limits!
# Some models have lower limits than Claude Code defaults
# e.g., claude-3-opus-20240229: 4096 tokens vs 21333 requested
# Check: https://docs.anthropic.com/en/docs/about-claude/models/overview
---
```
3. Write the command prompt
4. **Important**: Ask Claude to optimize it!

## File Naming Conventions

| Component | Convention | Example |
|-----------|-----------|---------|
| Agents | lowercase-hyphenated.md | `memory-keeper.md` |
| Task Templates | {command}-{purpose}.md | `commit-and-push-analyzer.md` |
| Commands | lowercase-hyphenated.md | `commit-and-push.md` |
| Directives | descriptive_names.md | `development_projects_directives.md` |

## Building and Maintaining Directives

### Understanding CLAUDE_global_directives.md

The `CLAUDE_global_directives.md` file is **automatically generated** and should **NEVER be edited manually**.

### Building Process

The `rebuild_claude_md.sh` script:
1. Collects all directive files from `directives/` (excluding .gitignore and .local.md files)
2. Aggregates their content into a single file
3. Adds metadata including build timestamp
4. Creates the final `CLAUDE_global_directives.md`

### When to Rebuild

Run `./rebuild_claude_md.sh` when you:
- Add a new directive file to `directives/`
- Modify any existing directive file
- Delete a directive file

```bash
# From repository root
./rebuild_claude_md.sh
```

### Directive File Guidelines

- Use clear, descriptive filenames
- Prefix with numbers for ordering (e.g., `0100_general.md`, `0200_python.md`)
- `.local.md` files are ignored by the build process
- Keep directives focused and modular

## The Power of Automatic Optimization

### How It Works

The framework includes two powerful optimizers that are **automatically triggered** when you ask:

1. **subagent-optimizer**: Automatically invoked when you mention optimizing an agent
2. **command-optimizer**: Automatically invoked when you mention optimizing a command

### Triggering Optimization

Simply ask Claude naturally:
- "Optimize my new agent"
- "Please improve this command"
- "Make this agent more effective"
- "Review this command for best practices"

The optimizers will:
- ✅ Run automatically without explicit invocation
- ✅ Apply current best practices
- ✅ Ensure proper structure and formatting
- ✅ Optimize for maximum effectiveness
- ✅ Work idempotently (only change what needs changing)

### What Gets Optimized

**For Agents (subagent-optimizer):**
- Description clarity for auto-invocation
- Model selection (haiku/sonnet/opus)
- Proactive settings
- Semantic color assignment
- YAML frontmatter structure

**For Commands (command-optimizer):**
- Tool permissions (security audit)
- Argument hints and usage
- Placeholder handling
- Description accuracy
- Removal of problematic fields

## Testing Your Work

### In This Repository
- **Test agents**: Use Task tool with the agent name
- **Test commands**: Type the slash command
- **Test optimization**: Just ask Claude to optimize!
- **Test maintenance**: Use `/maintenance:update-knowledge-base`

### In Other Projects
- Your new agents/commands are immediately available
- No need to reinstall or update
- Changes propagate via symlinks
- Optimization works everywhere

## Best Practices

### Agent Development
1. **Single Responsibility**: Each agent should do one thing well
2. **Clear Boundaries**: Define what the agent will and won't do
3. **Automatic Invocation Design**: Include "MUST BE USED PROACTIVELY" in description for agents that should trigger automatically
4. **Model Selection**:
   - `haiku`: Simple, fast tasks (parallel workers)
   - `sonnet`: Default for most agents
   - `opus`: Complex reasoning or creativity
5. **Naming**: Use descriptive, action-oriented names

### Command Development
1. **Namespace Appropriately**: Group related commands
2. **Tool Permissions**: Request minimum necessary tools
3. **Argument Hints**: Provide clear usage examples
4. **Error Handling**: Include graceful failure paths
5. **Documentation**: Commands are self-documenting via frontmatter

### Task Template Pattern (for parallelization)

For commands that benefit from parallelization:

1. **Create task templates** in `tasks/` directory with `{command}-{function}.md` naming
2. **Design for independence** - no shared state between parallel tasks
3. **Return structured data** (JSON preferred) for aggregation
4. **Limit to focused tasks** that can run concurrently
5. **No YAML frontmatter** - task templates are pure prompts

Example structure:
```markdown
# Task: Analyze specific aspect for mycommand

You are analyzing [specific aspect]. Focus on [specific criteria].

Note: This task operates without conversation context.

Return your findings as structured JSON.
```

Usage in commands:
```markdown
template = Read('tasks/mycommand-analyzer.md')
Task(subagent_type: 'general-purpose', prompt: template + context)
```

## Maintenance Commands

### Framework-Only Commands

Located in `.claude/commands/maintenance/`, these are only available when working in this repository:

#### /maintenance:update-knowledge-base
- Updates embedded Claude Code knowledge
- Fetches latest documentation
- Identifies outdated patterns
- Run quarterly or after Claude Code releases

## Version Control Guidelines

### What to Commit
- All `.md` files in agents/, commands/, directives/
- Setup scripts and utilities
- Documentation updates
- CLAUDE.md changes

### What to Ignore
- `.local.md` files (personal customizations)
- `.local.json` files (local settings)
- Generated files (unless needed for distribution)
- Personal test files

## Troubleshooting

### Agent Not Triggering
1. Check for "MUST BE USED PROACTIVELY" in description
2. Verify description contains clear trigger words
3. Test with explicit Task tool invocation
4. Run agent through optimizer

### Command Not Found
1. Verify file location matches namespace structure
2. Check YAML frontmatter syntax
3. If using `model` field, verify token compatibility
4. Verify symlinks are set up (`ls -la ~/.claude/`)

### Changes Not Reflecting
1. Symlinks update immediately - no rebuild needed
2. For directives, run `./rebuild_claude_md.sh`
3. Check file permissions
4. Verify you're editing in the framework repo, not ~/.claude/

## Contributing

### Before Submitting Changes
1. Test all modified components
2. Run optimizers on new agents/commands
3. Update documentation if needed
4. Ensure consistent naming conventions
5. Add examples for complex features

### Quality Checklist
- [ ] Component has clear, descriptive name
- [ ] YAML frontmatter is complete and valid
- [ ] Description enables automatic invocation (agents)
- [ ] Tool permissions follow least privilege (commands)
- [ ] Documentation updated if needed
- [ ] Tested in isolation and integration