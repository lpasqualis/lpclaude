# Advanced Patterns Guide

Expert techniques for power users of the Claude Framework.

## Parallel Processing with Task Templates

### The Pattern
Replace sequential processing with parallel execution using task templates:

```markdown
# In your command
template = Read('workers/analyzer.md')

# Execute up to 10 parallel tasks
results = []
for item in items[:10]:
    result = Task(
        subagent_type: 'general-purpose', 
        prompt: template + item_context
    )
    results.append(result)
```

### Creating Task Templates
1. Create file in `workers/{command}-{purpose}.md`
2. Write pure prompt (no YAML frontmatter)
3. Design for independence (no shared state)
4. Return structured data (JSON preferred)

### When to Use Parallel Processing
- Multiple independent analyses
- File-by-file processing
- Batch operations
- Performance-critical workflows

## Multi-Agent Orchestration

### Command → Worker Pattern
Commands can spawn parallel workers for complex tasks:

```yaml
---
name: /namespace:complex-command
allowed-tools: Task, Read, Write  # Task enables parallelization
---
```

### Execution Hierarchy
```
Main Claude
  → Commands (can use Task)
    → Workers (run in parallel, no Task access)
      → Return structured results
```

### Best Practices
- Limit to 10 concurrent tasks
- Design workers to be stateless
- Use structured data for aggregation
- Handle partial failures gracefully

## Automatic Agent Invocation

### Making Agents Proactive
Include trigger phrase in description:
```yaml
description: |
  Expert optimizer that MUST BE USED PROACTIVELY 
  when optimization is mentioned or needed.
```

### Trigger Word Strategy
- Use specific action verbs
- Include domain keywords
- Add "MUST BE USED PROACTIVELY"
- Test with natural language

## Command Composition

### Namespace Organization
```
/domain:action-target
/git:commit-and-push
/docs:capture-session
/implan:create
```

### Command Chaining
Commands can reference other commands:
```markdown
First, run /memory:learn to capture insights
Then execute /git:commit-and-push
```

### Stop Conditions
For long-running commands:
- "N files" - process count limit
- "N minutes" - time limit
- "until empty" - queue completion
- "until error" - fail-fast mode

## Optimization Workflows

### Batch Optimization
```bash
# Optimize all agents
for agent in agents/*.md; do
  echo "Optimize $agent"
done

# Optimize all commands
for cmd in commands/**/*.md; do
  echo "Optimize $cmd"
done
```

### Idempotent Operations
Optimizers track changes with timestamps:
```html
<!-- OPTIMIZATION_TIMESTAMP: 2025-08-10 21:23:45 -->
```

## Framework Extension Patterns

### Creating Domain-Specific Agents
1. Identify repetitive tasks
2. Extract common patterns
3. Create specialized agent
4. Add proactive triggers
5. Optimize for auto-invocation

### Building Command Ecosystems
1. Start with single-purpose commands
2. Identify common workflows
3. Create orchestration commands
4. Add parallel processing where beneficial
5. Document command relationships

## Performance Optimization

### Parallel vs Sequential
- **Use parallel for**: Independent tasks, batch processing, multi-file operations
- **Use sequential for**: Dependent operations, stateful workflows, user interaction

### Resource Management
- Max 10 concurrent tasks
- Monitor system resources
- Implement adaptive batching
- Handle backpressure gracefully

## Security Patterns

### Tool Permission Models
```yaml
# Read-only access
allowed-tools: Read, LS, Glob, Grep

# File modification
allowed-tools: Read, Write, Edit, MultiEdit, LS, Glob, Grep

# Full orchestration
allowed-tools: Task, Read, Write, Edit, Bash, LS, Glob, Grep
```

### Principle of Least Privilege
- Request minimum necessary tools
- Avoid Bash unless essential
- Never grant Task to agents
- Audit permissions regularly

## Testing Strategies

### Component Testing
```bash
# Test agent in isolation
Task(subagent_type: 'my-agent', prompt: 'test scenario')

# Test command with mock data
/my:command test-argument

# Verify optimization
"Optimize and test agents/my-agent.md"
```

### Integration Testing
- Test command chains
- Verify parallel execution
- Check error handling
- Validate output formats