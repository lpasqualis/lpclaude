---
name: /commands:validate
description: Validate existing Claude Code commands against best practices
argument-hint: "[command-name] [optional-validation-focus]"
allowed-tools: Read, LS, Glob, Grep, Task
---

Validate an existing command against current best practices and suggest improvements.

## Command Location

Determine the command file path:
- If name starts with `/`, extract: `/namespace:command` → `namespace/command.md`
- Search in `.claude/commands/` first, then `~/.claude/commands/`

## Validation Process

Use the existing validation task template:

```markdown
template = Read('workers/commands-validate-workers/command-validator.md')
command_content = Read('[command-file-path]')
Task(subagent_type: 'general-purpose', prompt: template + '\n\nCOMMAND TO VALIDATE:\n' + command_content)
```

## Validation Areas

The validator will assess:

### YAML Frontmatter
- Required fields (name, description)
- Tool permission completeness
- Argument hint appropriateness
- Model selection warnings

### Prompt Quality
- Clarity and specificity
- Proper placeholder usage
- Structural organization
- Context handling

### Best Practices Compliance
- Security considerations
- Performance patterns
- Maintainability
- User experience

### Anti-Pattern Detection
- Monolithic commands
- Incomplete tool groupings
- Process vs practice misalignment
- Security vulnerabilities

## Output Format

Present validation results with:
- Compliant areas
- Issues found with specific recommendations
- Optimization opportunities
- Prioritized action items

$ARGUMENTS