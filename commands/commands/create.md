---
name: /commands:create
description: Interactive command creator - helps you create new Claude Code commands
argument-hint: "[desired command name] (optional - if not provided, will suggest names based on purpose)"
allowed-tools: Read, Write, Edit, MultiEdit, LS, Glob, Grep, Task, WebFetch, WebSearch
---
<!-- OPTIMIZATION_TIMESTAMP: 2025-08-08 08:42:51 -->

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
- **Complexity**: Low to medium - follows pre-defined instructions

### **Workflow Commands** (Multi-Agent Orchestrators)  
- **Characteristics**: Complex, multi-faceted problem requiring coordination
- **Examples**: `/feature-development`, `/legacy-modernize`, `/smart-fix`
- **When to use**: Solution path is not known in advance, requires emergent problem-solving
- **Complexity**: High - coordinates multiple specialized agents

Explain the classification to the user and confirm which type fits their needs.

## 4. Define Command Details

Work with the user to determine:
- **Command name**: If provided in ARGUMENTS, suggest using it. Otherwise, propose names based on the purpose
- **Arguments needed**: Will it accept arguments? What format?
- **Tool permissions**: Based on command functionality requirements
- **Required tools**: Use PERMISSIVE tool groupings (see Tool Permission Guidelines below)
- **Frontmatter needed**: Determine if description, argument-hint, or allowed-tools metadata is needed
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

**IMPORTANT**: Most commands do NOT need parallel execution. Only consider parallelization for specific scenarios.

### When Parallelization is APPROPRIATE:
- **Independent data collection**: Reading/analyzing multiple files, directories, or data sources
- **Parallel validation**: Checking multiple components against the same criteria
- **Batch read-only analysis**: Security scans, code quality checks, documentation reviews
- **Research aggregation**: Gathering information from multiple independent sources

### When Parallelization is INAPPROPRIATE:
- **Implementation/execution workflows**: Building, deploying, installing, or modifying systems
- **Sequential operations**: Tasks with dependencies where one step must complete before the next
- **Tasks requiring subagents**: Parallel workers cannot use the Task tool or invoke other subagents
- **Context-dependent operations**: Tasks that need conversation history or user interaction
- **File modification workflows**: Risk of conflicts when multiple workers modify the same resources
- **Single-target operations**: Commands that work on one specific thing at a time

### Critical Constraints for Parallel Workers:
1. **No subagent access**: Parallel workers cannot use the Task tool or invoke other subagents
2. **No conversation context**: Workers start fresh without access to conversation history
3. **Isolated execution**: Each worker operates independently with no inter-worker communication
4. **Result aggregation only**: Workers return results that the main command aggregates

### How to Implement Parallelization (Only if Appropriate):

#### Option A: Direct Parallel Task Instructions (Simple)
For basic read-only parallel operations:
```markdown
When analyzing multiple independent [targets]:
- Use Task tool to create parallel analysis tasks
- Limit to 10 parallel tasks (system limit)
- Each task analyzes one [target] independently
- Aggregate results from all tasks
```

#### Option B: Create Supporting Subagents (Complex)
Only for sophisticated read-only parallel operations that meet ALL criteria:
- ✅ Purely analytical (no modifications)
- ✅ Independent subtasks (no dependencies)
- ✅ No need for subagents or context
- ✅ Combinable discrete results

1. **Create companion subagent(s)** in the `agents/` directory:
   - Name: `cmd-[command-name]-analyzer.md` (use "analyzer" for read-only)
   - Purpose: Handle specific analysis subtasks in isolation
   - Tools: Minimal read-only set (typically: Read, LS, Glob, Grep)
   - Proactive: Always set to `false` for command-specific subagents

2. **Update command to orchestrate analysis**:
   ```markdown
   For analyzing multiple [targets]:
   - Use Task tool with subagent_type: 'cmd-[command-name]-analyzer'
   - Run up to 10 instances in parallel for different [targets]
   - Aggregate analysis results and present unified findings
   ```

### Decision Framework:
Ask these questions before suggesting parallelization:
1. Does the command perform read-only analysis of multiple independent items? (If No → No parallelization)
2. Can the work be split into completely independent subtasks? (If No → No parallelization)  
3. Do the subtasks need subagents, context, or sequential dependencies? (If Yes → No parallelization)
4. Will parallel execution provide significant benefit over sequential processing? (If No → No parallelization)

**Default recommendation**: Most commands should NOT use parallelization. Only suggest it for clear cases of independent, read-only analysis tasks.

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

## 7. Draft and Validate the Command

Create an initial command draft that:
- Clearly instructs the AI agent what to do (not what to tell the user)
- Includes any necessary context or constraints
- Properly handles arguments if applicable
- Follows the pattern of existing commands in the commands folder
- Incorporates parallelization strategy if applicable

### Parallel Validation Process
Once the draft is complete, use the Task tool for efficient validation:

```markdown
Use Task tool with:
- subagent_type: 'cmd-create-command-validator'  
- Include the command draft and any companion subagents in the task
- Request comprehensive validation covering YAML, prompt quality, and architectural patterns
```

Apply validation feedback to optimize the draft before presenting to user.

Show the validated, optimized draft to the user and ask for feedback.

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
- **Run final validation** using Task tool with `cmd-create-command-validator` to ensure all components are optimized
- Confirm successful creation and provide summary of all created components

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

### Validation Integration:
- **Parallel Validation**: Use `cmd-create-command-validator` subagent for efficient quality assurance
- **Continuous Improvement**: Apply validation feedback iteratively during creation process
- **Quality Gates**: Don't proceed to next step without addressing validation issues
- **Best Practice Enforcement**: Validate against current standards, not outdated patterns

### Security Best Practices:
- **Never use `--dangerously-skip-permissions`**: Use frontmatter `allowed-tools` instead
- **Principle of least privilege**: While being permissive within reason, don't add completely unrelated tools
- **Sensitive operations**: Add confirmation prompts for destructive or high-risk operations
- **No hardcoded secrets**: Never include API keys, passwords, or tokens in command definitions

## Process Optimization and Efficiency

### Parallel Creation Workflow
When creating complex commands with multiple components:

1. **Requirements Analysis**: Use Task tool with `cmd-create-command-validator` to analyze requirements
2. **Component Creation**: Create main command first, then create companion subagents if needed
3. **Validation**: Use Task tool to validate all components against best practices
4. **Integration Testing**: Ensure command and subagent coordination works effectively

### Efficiency Guidelines for Complex Commands

When creating commands that perform extensive operations:

1. **Context Management**: Remember that subagents start with fresh context, reducing token usage for parallel tasks
2. **Task Independence**: Ensure parallel tasks don't depend on each other or modify the same resources
3. **Smart Batching**: Group related operations that can share context, separate those that can run independently
4. **Result Aggregation**: Design clear patterns for combining results from parallel operations
5. **Performance Metrics**: Consider adding progress indicators for long-running parallel operations
6. **Validation Integration**: Use Task tool with validation subagents throughout creation, not just at the end
