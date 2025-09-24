# Subagents vs Commands vs Tasks: When to Use Each

This guide clarifies when to use subagents, slash commands, or the Task tool in the Claude Framework.

## Quick Decision Guide

### Use **Subagents** When You Need:
- **Separate context window** - Prevents main conversation pollution
- **Parallelization potential** - Multiple subagents can run simultaneously
- **Specialized expertise** - Task-specific system prompts and behaviors  
- **Automatic delegation** - Claude proactively invokes based on task description
- **Complex, multi-step operations** - Can handle substantial workloads independently
- **Restricted tool access** - Can limit which tools the subagent can use

**Examples**: code-reviewer, debugger, security-auditor, test-runner, documentation-auditor

### Use **Slash Commands** When You Need:
- **Reusable prompts** - Frequently used instructions stored as markdown
- **User-triggered actions** - Explicitly invoked by typing /command
- **Quick context injection** - Include files (@), bash output (!), arguments ($1, $2)
- **Model/tool overrides** - Specify different model or tool permissions via frontmatter
- **Simple, focused tasks** - Single-purpose operations without complex logic
- **Commands that spawn workers** - Can use Task tool to create parallel workers

**Examples**: /fix-issue, /commit, /optimize, /security-review, /doublecheck

### Use **Task Tool** (Direct Invocation) When You Need:
- **One-off delegation** - Temporary task that doesn't warrant a saved subagent
- **Dynamic task definition** - Create task instructions on the fly
- **Research or exploration** - Open-ended searches requiring multiple rounds
- **Single focused delegation** - One specific task to complete

**Examples**: "Search for all error handling patterns", "Analyze this codebase structure"

## Parallelization Capabilities

One of the **key advantages of subagents** is their ability to run in parallel since each operates in a separate context window:

### Parallelization Comparison

| Method | Parallel Capability | Use Case |
|--------|-------------------|----------|
| **Multiple Subagents** | ✅ Excellent - separate contexts | Independent specialized tasks |
| **Slash Command** | ✅ Can spawn parallel workers via Task | User-triggered parallel jobs |
| **Direct Task Tool** | ⚠️ Single task only | One focused delegation |
| **Main Claude** | ❌ Sequential only | Linear conversation flow |

### Parallel Execution Example

Claude can invoke multiple subagents simultaneously:
```
# These all run in parallel, each in their own context:
Task → code-reviewer (reviewing changes)
Task → test-runner (running tests)  
Task → documentation-auditor (checking docs)
Task → security-auditor (scanning for vulnerabilities)
```

## Key Differences Table

| Aspect | Subagent | Slash Command | Task Tool |
|--------|----------|---------------|-----------|
| **Invocation** | Automatic or explicit | User types /command | Programmatic in code |
| **Context** | Separate window | Main conversation | Separate window |
| **Persistence** | Saved as .md file | Saved as .md file | Ephemeral |
| **Best for** | Complex specialized tasks | Reusable prompts | One-off delegations |
| **Can use Task tool** | No | Yes | No (can't nest) |
| **Parallelization** | Excellent (multiple can run) | Good (can spawn workers) | Limited (single task) |
| **Proactive use** | Yes (auto-triggered) | No (user-triggered) | Yes (Claude decides) |

## Framework Execution Hierarchy

Understanding the execution hierarchy helps clarify capabilities:

```
Main Claude
├── Can use Task → Invoke any subagent (parallel OK)
├── Can execute → Slash commands
│   └── Commands → Can use Task → Invoke workers (parallel OK)
│                → Can execute other commands via SlashCommand tool
└── Subagents/Workers → Cannot use Task tool
                      → Can execute commands via SlashCommand tool
```

### Key Constraints
- **Subagents CANNOT have Task tool** - Filtered at framework level
- **Commands CAN use Task** for parallel execution (up to 10 concurrent)
- **No recursive delegation** - Tasks can't spawn Tasks
- **Subagents only trigger on user input**, never on Claude's output
- **Agent changes require Claude Code restart** - Agents load at startup only

## Decision Flowchart

```
Is this a frequently-used operation?
├─ Yes → Will the user always trigger it manually?
│        ├─ Yes → **Slash Command**
│        └─ No → **Subagent** (for automatic invocation)
└─ No → Is it a complex, specialized task?
         ├─ Yes → Do you want parallelization potential?
         │        ├─ Yes → **Subagent**
         │        └─ No → **Direct Task Tool**
         └─ No → **Direct implementation in main Claude**
```

## Best Practices

### For Subagents
1. **Design for independence** - Each subagent should be self-contained
2. **Enable parallelization** - Write subagents that can run simultaneously
3. **Use "MUST BE USED PROACTIVELY"** in description for automatic triggering
4. **Limit tool access** - Only grant necessary tools for security
5. **Make them specialized** - Single-purpose subagents work best

### For Slash Commands  
1. **Keep them simple** - Commands should be quick shortcuts
2. **Use frontmatter** - Specify tools, model, and argument hints
3. **Leverage arguments** - Use $1, $2 for flexible commands
4. **Include context** - Use @ for files, ! for bash output
5. **Document clearly** - Good descriptions help discoverability

### For Task Tool
1. **Provide complete context** - Task runs in isolation
2. **Be specific** - Clear instructions prevent ambiguity
3. **Consider making it a subagent** - If you use it repeatedly
4. **Don't nest Tasks** - Tasks cannot spawn other Tasks
5. **Use for research** - Great for open-ended exploration

## Common Patterns

### Pattern 1: Parallel Code Review
Create multiple specialized reviewers as subagents:
- `security-reviewer` - Focuses on vulnerabilities
- `performance-reviewer` - Looks for bottlenecks  
- `style-reviewer` - Checks code conventions

Claude can run all three simultaneously after code changes.

### Pattern 2: Command with Workers
Slash command that spawns parallel workers:
```markdown
---
allowed-tools: Task
---
Use the Task tool to run these checks in parallel:
1. Check for unused dependencies
2. Validate all imports
3. Find duplicate code
```

### Pattern 3: Progressive Enhancement
1. Start with direct implementation
2. If repeated, create a slash command
3. If needs automation, convert to subagent
4. If benefits from parallelization, ensure subagent design supports it

## Summary

**Rule of thumb**: 
- **Subagents** for specialized expertise and parallelization
- **Commands** for user-triggered shortcuts and workflows
- **Task** for one-off delegations and research

The key insight about parallelization: Since subagents run in separate context windows, they're ideal when you want Claude to potentially parallelize specialized work automatically, leveraging their independent contexts for efficient concurrent processing.