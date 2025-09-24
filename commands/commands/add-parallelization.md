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

1. **Create Worker Subdirectory**: Create directory based on command format:
   - Simple commands: `workers/[command-name]-workers/`
   - Namespaced commands: `workers/[namespace]-[name]-workers/`
2. **Generate Worker Templates**: Create specific worker tasks in the subdirectory
3. **Update Command**: Add parallel execution instructions using Task tool
4. **Add Batching Logic**: Handle system limit of 10 parallel tasks
5. **Result Aggregation**: Pattern for combining worker outputs

### Task Template Pattern:
Store in appropriate subdirectory:
- Simple: `workers/[command-name]-workers/[worker-type].md`
- Namespaced: `workers/[namespace]-[name]-workers/[worker-type].md`
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
- Read template: Read('workers/[namespace]-[name]-workers/analyzer.md')
  (or 'workers/[command-name]-workers/analyzer.md' for simple commands)
- Use Task tool with subagent_type: 'general-purpose'
- Process up to 10 [targets] in parallel
- Aggregate results and present unified findings
```

## Validation

Ensure the updated command:
- Maintains original functionality for single targets
- Preserves all existing frontmatter (including disable-model-invocation if present)
- Uses Task tool appropriately
- Includes proper error handling
- Documents parallelization clearly

Note: If the command has `disable-model-invocation: true`, preserve it - parallel execution capability doesn't change whether Claude should invoke it programmatically.

$ARGUMENTS