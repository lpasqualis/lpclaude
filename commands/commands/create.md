---
name: /commands:create
description: Create new Claude Code commands with best practices and automatic validation
argument-hint: "[description of what the command should do] (command name optional - can be embedded in description or will be generated)"
allowed-tools: Read, Write, Edit, MultiEdit, LS, Glob, Grep, Task, WebFetch
---
<!-- OPTIMIZATION_TIMESTAMP: 2025-08-26 21:24:23 -->

## Command Creation Process

Parse the user's input to extract:
1. **Command description**: What the command should do
2. **Command name**: Extract from patterns like "/command-name", "called [name]", or generate from description
3. **Scope**: Default to project-local (`.claude/commands/`) unless "global" or "all projects" mentioned

## Requirements Analysis

From the description, determine:
- Core functionality and purpose
- Required tools based on operations needed
- Command type (Tool vs Workflow)
- Whether arguments are needed

## Tool Permission Selection

Use complete logical groupings:
- File exploration: `Read, LS, Glob, Grep`
- File modification: `Read, Write, Edit, MultiEdit, LS, Glob, Grep`
- Web research: `WebFetch, WebSearch`
- Git operations: `Bash, Read, LS, Glob, Grep`
- Complex workflows: Add `Task` for subagent coordination

## Command Structure

**Commands are USER INPUT TEMPLATES** - write in second person as instructions TO Claude:

### Basic Structure:
```markdown
---
name: /command-name
description: Brief description of functionality
argument-hint: [specific arguments expected]
allowed-tools: [appropriate tool grouping]
---

[Concise, directive instructions]

$ARGUMENTS

[Any constraints or output format requirements]
```

## Implementation Steps

1. **Analyze Requirements**: Determine command type and scope
2. **Generate YAML Frontmatter**: Include all required fields with logical tool groupings
3. **Write Command Body**: Use concise, directive language with clear steps
4. **Add $ARGUMENTS Placeholder**: Allow natural language customization
5. **Validate Draft**: Use existing validation task template
6. **Create Command File**: Save in appropriate directory
7. **Confirm Creation**: Provide brief summary

## Validation Integration

For complex commands requiring validation:
```markdown
template = Read('tasks/create-command-validator.md')
Task(subagent_type: 'general-purpose', prompt: template + draft_command)
```

Apply validation feedback to optimize the command before saving.

## Best Practices

- **Be autonomous**: Create immediately with reasonable assumptions
- **Stay focused**: One clear purpose per command
- **Use directive language**: "Analyze", "Generate", "Review"
- **Include $ARGUMENTS**: Allow user customization
- **Validate early**: Check against best practices during creation

$ARGUMENTS
