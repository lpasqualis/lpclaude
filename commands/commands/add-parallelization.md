---
name: /commands:add-parallelization
description: Add parallel execution capabilities to existing Claude Code commands
argument-hint: "[command-name] [optional-specific-requirements]"
allowed-tools: Read, Write, Edit, MultiEdit, LS, Glob, Grep
---

Analyze an existing command and add parallelization capabilities when appropriate.

## Parallelization Analysis

First, read the target command file:
- If command name starts with `/`, determine path: `/namespace:command` → `namespace/command.md`
- Look in `.claude/commands/` first, then `~/.claude/commands/`

## Suitability Assessment

Only add parallelization if the command performs:
- **Independent data collection**: Reading/analyzing multiple files or components
- **Batch read-only analysis**: Security scans, code quality checks, validation
- **Research aggregation**: Gathering information from multiple sources

**Do NOT parallelize**:
- Implementation/deployment workflows
- Sequential operations with dependencies
- Single-target operations
- File modification workflows

## Implementation Strategy

If parallelization is appropriate:

1. **Create Task Template**: Generate `tasks/[command-name]-analyzer.md` for worker tasks
2. **Update Command**: Add parallel execution instructions using Task tool
3. **Add Batching Logic**: Handle system limit of 10 parallel tasks
4. **Result Aggregation**: Pattern for combining worker outputs

### Task Template Pattern:
```markdown
You are a specialized worker for parallel [analysis-type]. 

Analyze the provided [target] for [specific-criteria].

Return results in structured format:
- Item: [target-identifier]
- Status: [result-summary]
- Details: [specific-findings]

This task operates without conversation context.
```

### Command Integration Pattern:
```markdown
For multiple [targets]:
- Read template: Read('tasks/[command-name]-analyzer.md')
- Use Task tool with subagent_type: 'general-purpose'
- Process up to 10 [targets] in parallel
- Aggregate results and present unified findings
```

## Validation

Ensure the updated command:
- Maintains original functionality for single targets
- Uses Task tool appropriately
- Includes proper error handling
- Documents parallelization clearly

$ARGUMENTS