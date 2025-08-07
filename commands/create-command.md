---
description: Interactive command creator - helps you create new Claude Code commands
argument-hint: "[desired command name] (optional - if not provided, will suggest names based on purpose)"
allowed-tools: Read, Write, LS, Glob, Grep, Task, WebFetch
---

First of all, learn about Claude commands here: https://docs.anthropic.com/en/docs/claude-code/slash-commands
Then, guide the user through creating a new Claude Code command interactively. Follow this process:

## 1. Determine Command Type

Ask the user whether they want to create:
- **Project command** (stored in `.claude/commands/` - shared with team)
- **Personal command** (stored in `~/.claude/commands/` - available across all projects)

If unclear, explain the difference and wait for their choice.

## 2. Gather Requirements

Ask the user to describe:
- What the command should do
- What problem it solves
- When they would use it

Based on their response, ask clarifying questions as needed to fully understand the intent and/or to help the user decide what they want the command to really do.

## 3. Classify Command Architecture: Workflow vs Tool

Based on the requirements, determine the command type:

### **Tool Commands** (Single-Purpose Utilities)
- **Characteristics**: Well-defined, specific task with clear steps
- **Examples**: `/api-scaffold`, `/doc-generate`, `/security-scan`
- **When to use**: Task has objective success criteria and follows a defined procedure
- **Model**: Usually `haiku` or `sonnet` for efficiency
- **Complexity**: Low to medium - follows pre-defined instructions

### **Workflow Commands** (Multi-Agent Orchestrators)  
- **Characteristics**: Complex, multi-faceted problem requiring coordination
- **Examples**: `/feature-development`, `/legacy-modernize`, `/smart-fix`
- **When to use**: Solution path is not known in advance, requires emergent problem-solving
- **Model**: Usually `sonnet` or `opus` for complex reasoning
- **Complexity**: High - coordinates multiple specialized agents

Explain the classification to the user and confirm which type fits their needs.

## 4. Define Command Details

Work with the user to determine:
- **Command name**: If provided in ARGUMENTS, suggest using it. Otherwise, propose names based on the purpose
- **Arguments needed**: Will it accept arguments? What format?
- **Model selection**: Based on command type (haiku for simple tools, sonnet for complex analysis, opus for critical reasoning)
- **Required tools**: Use PERMISSIVE tool groupings (see Tool Permission Guidelines below)
- **Frontmatter needed**: Determine if description, argument-hint, model, or allowed-tools metadata is needed
- **Parallelization needs**: Analyze if the command will perform complex, multi-step operations that could benefit from parallel execution

### Tool Permission Guidelines (BE PERMISSIVE!)

**IMPORTANT**: Commands inherit permissions from their caller, and users are prompted for new permissions. Being overly restrictive causes unnecessary friction. Use these logical groupings:

#### Standard Tool Groupings:
```yaml
# For ANY file reading/exploration:
allowed-tools: Read, LS, Glob, Grep

# For ANY file modification (always include all):
allowed-tools: Read, Write, Edit, MultiEdit, LS, Glob, Grep

# For web research (always include both):
allowed-tools: WebFetch, WebSearch

# For git/repository operations:
allowed-tools: Bash, Read, LS, Glob, Grep

# For complex analysis/refactoring:
allowed-tools: Read, Write, Edit, MultiEdit, LS, Glob, Grep, Task

# For comprehensive workflows:
allowed-tools: Read, Write, Edit, MultiEdit, LS, Glob, Grep, Bash, Task, WebFetch, WebSearch
```

**Key Principle**: If a command might reasonably need a tool, include it. Only exclude tools that are completely unrelated to the command's purpose.

## 5. Analyze Parallelization Opportunities

If the command involves complex operations, evaluate whether it could benefit from parallel execution:

### When to Consider Parallelization:
- **Multiple independent analyses**: e.g., analyzing different directories, checking multiple files for patterns
- **Batch operations**: e.g., refactoring multiple files, generating tests for multiple components
- **Multi-aspect evaluation**: e.g., security audit + performance analysis + code quality review
- **Research tasks**: e.g., checking documentation across multiple sources simultaneously

### How to Implement Parallelization:

#### Option A: Direct Parallel Task Instructions (Simple)
For commands that need basic parallelization, include instructions like:
```markdown
When processing multiple files/directories, use the Task tool to create parallel subagents:
- Create up to 10 parallel tasks (system limit)
- Each task should handle an independent portion of work
- Ensure tasks don't modify the same files simultaneously
```

#### Option B: Create Supporting Subagents (Complex)
For commands requiring sophisticated parallel operations, create dedicated subagent(s):

1. **Identify decomposable subtasks** that:
   - Can run independently without full context
   - Don't require access to conversation history
   - Produce discrete, combinable results

2. **Create companion subagent(s)** in the `agents/` directory:
   - Name: `cmd-[command-name]-worker.md` or `cmd-[command-name]-analyzer.md`
   - Purpose: Handle specific subtasks in isolation
   - Tools: Minimal set required for the subtask
   - Model: Usually 'haiku' for simple tasks, 'sonnet' for complex
   - Proactive: Always set to `false` for command-specific subagents

3. **Update command to orchestrate subagents**:
   ```markdown
   For [complex operation], delegate to specialized subagents:
   - Use Task tool with subagent_type: 'cmd-[command-name]-worker'
   - Run up to 10 instances in parallel for different [targets]
   - Aggregate results and present unified output
   ```

### Example Parallelization Pattern:
```markdown
# For analyzing multiple components simultaneously:
1. Identify all [targets] to analyze
2. If more than 3 [targets], use parallel execution:
   - Create tasks for each [target] using Task tool
   - Specify subagent_type: 'analyzer' (if created) or use general-purpose
   - Batch into groups of 10 if exceeding system limit
3. Collect and synthesize results from all parallel tasks
4. Present consolidated findings to user
```

## 6. Add Prompt Chaining for Complex Workflows

For **Workflow Commands** that involve multiple cognitive steps, use prompt chaining to improve reliability:

### Prompt Chaining Pattern:
```markdown
## Step 1: Analysis
First, analyze [target] for [criteria], enclosing your findings in <analysis> tags.

## Step 2: Synthesis  
Next, synthesize the findings to identify [patterns/issues], enclosing in <synthesis> tags.

## Step 3: Generation
Finally, based on your analysis and synthesis, generate [output] formatted as [format].
```

### Self-Correction Loop Pattern:
```markdown
1. Generate initial [output]
2. Review your output against these criteria:
   - [Criterion 1]
   - [Criterion 2]
   Enclose review in <review> tags
3. If issues found, refine the output based on your review
4. Present final version
```

This ensures Claude gives full attention to each sub-task sequentially, dramatically improving accuracy.

## 7. Draft the Command

Create an initial command prompt that:
- Clearly instructs the AI agent what to do (not what to tell the user)
- Includes any necessary context or constraints
- Properly handles arguments if applicable
- Follows the pattern of existing commands in the commands folder
- Incorporates parallelization strategy if applicable
- Make sure the command is optimized using the @command-optimizer agent

Show the draft to the user and ask for feedback.

## 8. Iterate and Refine

Based on user feedback:
- Adjust the prompt wording
- Add or remove functionality
- Clarify instructions
- Refine parallelization strategy if needed
- Continue iterating until the user is satisfied

## 9. Finalize and Save the Command

Once approved:
- Save the command to the appropriate directory
- If companion subagents were created, save them to the `agents/` directory
- Confirm successful creation of all components
- Make sure the command is optimized using the @command-optimizer agent
- If subagents were created, optimize them using the @subagent-optimizer agent

## Important Notes

### Command Design Principles:
- Write commands as prompts TO the AI agent, not as messages FROM the agent
- Keep prompts clear and actionable
- Include specific instructions about output format when relevant
- Consider edge cases and include appropriate handling
- **Automate processes, not practices**: Focus on well-defined tasks with objective success criteria

### Context Management:
- **CLAUDE.md interaction**: Commands should respect project conventions in CLAUDE.md
- **Avoid "junk drawer" anti-pattern**: Don't add conflicting or untested instructions to CLAUDE.md
- **Session hygiene**: For long workflows, recommend using `/clear` between major phases
- **Context awareness**: Remember that subagents start with fresh context (good for parallel tasks)

### Security Best Practices:
- **Never use `--dangerously-skip-permissions`**: Use frontmatter `allowed-tools` instead
- **Principle of least privilege**: While being permissive within reason, don't add completely unrelated tools
- **Sensitive operations**: Add confirmation prompts for destructive or high-risk operations
- **No hardcoded secrets**: Never include API keys, passwords, or tokens in command definitions

## Efficiency Guidelines for Complex Commands

When creating commands that perform extensive operations:

1. **Context Management**: Remember that subagents start with fresh context, reducing token usage for parallel tasks
2. **Task Independence**: Ensure parallel tasks don't depend on each other or modify the same resources
3. **Smart Batching**: Group related operations that can share context, separate those that can run independently
4. **Model Selection**: Use lighter models (haiku) for simple parallel tasks, reserve heavier models for complex reasoning
5. **Result Aggregation**: Design clear patterns for combining results from parallel operations
6. **Performance Metrics**: Consider adding progress indicators for long-running parallel operations
