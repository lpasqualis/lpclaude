---
name: /lpclaude:cmd-agents-to-tasks-migration
description: Migrate cmd-* subagents to task templates in any Claude Code project
argument-hint: "[--backup-only] [--no-delete] [--dry-run]"
allowed-tools: Read, Write, Edit, MultiEdit, LS, Glob, Grep, Bash, TodoWrite
---

# CMD-* Agents to Task Templates Migration

This command migrates your project from the old cmd-* subagent pattern to the cleaner task template pattern for projects using the standard `.claude/` directory structure.

## Migration Process

### Phase 1: Analysis and Discovery

1. **Verify project structure**:
   - Confirm `.claude/` directory exists
   - Check for `.claude/agents/` and `.claude/commands/` directories
   - Exit with clear message if not a standard Claude project

2. **Inventory cmd-* agents**:
   - Use Glob to find all `.claude/agents/cmd-*.md` files
   - Count and list them for user confirmation
   - Identify which commands reference these agents

3. **Create backup snapshot**:
   - Create timestamped backup in `.claude/migration-backup-[timestamp]/`
   - Copy all cmd-* agents and affected commands
   - Report backup location to user

### Phase 2: Migration Execution

4. **Create tasks directory**:
   - Create `.claude/tasks/` directory
   - Verify directory creation

5. **Migrate each cmd-* agent to task template**:
   - Read each cmd-* agent file
   - Extract system prompt (content after YAML frontmatter)
   - Remove `cmd-` prefix from filename
   - Write to tasks directory
   - Verify content was extracted properly (not empty)

6. **Update command references**:
   - Find all commands in `.claude/commands/` that reference cmd-* agents
   - For each affected command:
     
     **Replace Task invocations:**
     - FROM: `Task(subagent_type: 'cmd-[name]', ...)`
     - TO: `template = Read('.claude/tasks/[name].md')`
           `Task(subagent_type: 'general-purpose', prompt: template + context)`
     
     **Update tool permissions:**
     - Add `Read` to allowed-tools if Task is present but Read is missing
     
   - Use MultiEdit for multiple changes in same file

### Phase 3: Validation and Cleanup

7. **Validate migration**:
   - Ensure all task files have content
   - Verify command updates were applied correctly
   - Check for any remaining cmd-* references

8. **Optional cleanup** (unless --no-delete specified):
   - Prompt user for confirmation
   - Delete original cmd-* agent files
   - Report deletion count

9. **Generate migration report**:
   - Summary of agents migrated
   - Commands updated
   - Any issues encountered
   - Location of backups
   - Next steps for testing

## Options Handling

- **--backup-only**: Only create backups, don't perform migration
- **--no-delete**: Keep original cmd-* files after migration
- **--dry-run**: Show what would be done without making changes

## Patterns to Transform

### Task Invocation Patterns
Look for and update:
- `subagent_type: 'cmd-[name]'` → Two-step: Read + Task with `general-purpose`
- Direct references to cmd-* agents in Task calls
- Any hardcoded cmd-* subagent names

### File Path References
Update paths if mentioned in command documentation:
- `.claude/agents/cmd-*.md` → `.claude/tasks/*.md`
- References to "cmd-* worker" → "task worker"

## Error Handling

- If YAML extraction fails, try alternative sed-based extraction
- If task file is empty after extraction, flag for manual review
- If command update fails, keep in list for manual intervention
- Report all issues clearly with suggested remediation

## Implementation Pattern

The migration will:
1. Use TodoWrite to track progress through migration steps
2. Provide real-time feedback as each agent is processed
3. Use Glob and Grep for efficient file discovery
4. Use MultiEdit for batch updates to commands
5. Create comprehensive backup before any destructive operations

## Expected Transformations

### Agent to Task Template
```
FROM: .claude/agents/cmd-analyzer.md (with YAML frontmatter)
TO:   .claude/tasks/analyzer.md (system prompt only)
```

### Command Task Invocation Updates
```
FROM: Task(subagent_type: 'cmd-analyzer', prompt: "analyze this...")

TO:   template = Read('.claude/tasks/analyzer.md')
      Task(subagent_type: 'general-purpose', prompt: template + "analyze this...")
```

### Tool Permissions Updates
```
FROM: allowed-tools: Task, Bash
TO:   allowed-tools: Read, Task, Bash
```

## Post-Migration Testing

After migration, advise user to:
1. Test each migrated command
2. Verify task templates load correctly
3. Check parallel execution still works
4. Commit changes to version control
5. Remove backup after verification

## Special Considerations

### YAML Frontmatter Extraction
Handle different formats when extracting system prompts:
- Standard `---` delimiters
- HTML comments after frontmatter (e.g., `<!-- OPTIMIZATION_TIMESTAMP -->`)
- Empty lines between sections
- Ensure extraction captures only the system prompt content

### Path Consistency
All paths use `.claude/` prefix for standard projects:
- Agents: `.claude/agents/cmd-*.md`
- Tasks: `.claude/tasks/*.md`
- Commands: `.claude/commands/**/*.md`

### Common Patterns
The command should handle these common cmd-* naming patterns:
- `cmd-[command]-analyzer` - Analysis workers
- `cmd-[command]-validator` - Validation workers
- `cmd-[command]-scanner` - Scanning workers
- `cmd-[command]-worker` - General processing workers

This command transforms your project to use the cleaner task template pattern, improving organization and reducing namespace pollution while maintaining full functionality.