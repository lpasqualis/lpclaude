---
name: /commands:create
description: Interactive command creator - helps you create new Claude Code commands
argument-hint: "[description of what the command should do] (command name optional - can be embedded in description or will be generated)"
allowed-tools: Read, Write, Edit, MultiEdit, LS, Glob, Grep, Task, WebFetch, WebSearch
---
<!-- OPTIMIZATION_TIMESTAMP: 2025-08-08 08:42:51 -->

First, reference Claude commands documentation: https://docs.anthropic.com/en/docs/claude-code/slash-commands

When model selection is being considered, fetch current models from: https://docs.anthropic.com/en/docs/about-claude/models/overview

## Core Principle: BE AUTONOMOUS

Create commands WITHOUT asking questions unless the request is genuinely ambiguous. Make reasonable assumptions:
- **Default to project-local** (`.claude/commands/`)
- **Default to Tool command type** (not Workflow) 
- **Extract or generate command name** from the description
- **Select tools based on functionality**
- **Create immediately**, refine if needed

Only ask for clarification if you truly cannot determine what the command should do.

## Input Processing

Parse the user's input to extract:
1. **Command description**: The full explanation of what the command should do
2. **Command name** (if provided): Look for patterns like:
   - "/command-name" explicitly mentioned
   - "called [name]" or "named [name]"
   - Commands referenced in quotes
   - If not found, generate from the description

Example inputs:
- "create a command that analyzes code quality and suggests improvements" → generates `/code-quality-analyzer`
- "I need a /deploy-staging command that deploys to staging environment" → uses `/deploy-staging`
- "make a command called security-scan that checks for vulnerabilities" → uses `/security-scan`

## 1. Determine Command Scope

**Default to PROJECT-LOCAL** unless the user explicitly mentions:
- "personal", "global", "all projects", "across projects" → Create in `~/.claude/commands/`
- Otherwise → Create in `.claude/commands/` (project-local)

Don't ask about scope - just proceed with project-local as the default.

## 2. Understand Requirements

From the user's description:
- Extract the core functionality and purpose
- Identify key operations the command needs to perform
- Determine if specific tools or capabilities are mentioned
- Make reasonable assumptions based on the description
- Only ask follow-up questions if the requirements are genuinely unclear
- Proceed with implementation rather than asking for excessive clarification

## 3. Automatically Classify Command Type

Based on the requirements, automatically determine and proceed with the appropriate type:

### **Tool Commands** (Default for most cases)
- **Use when**: Task has clear, defined steps
- **Examples**: `/api-scaffold`, `/doc-generate`, `/security-scan`
- **Characteristics**: Single-purpose, predictable execution

### **Workflow Commands** (For complex orchestration)  
- **Use when**: Task requires multiple steps, coordination, or emergent problem-solving
- **Examples**: `/feature-development`, `/legacy-modernize`
- **Characteristics**: Multi-agent coordination, complex decision trees

Don't ask the user - make the determination based on complexity and proceed.

## 4. Define Command Details Automatically

Determine without asking:
- **Command name**: Use provided name or generate based on purpose
- **Arguments needed**: Will it accept arguments? What format?
- **Tool permissions**: Based on command functionality requirements
- **Required tools**: Use PERMISSIVE tool groupings (see Tool Permission Guidelines below)
- **Model selection** (optional): Consider if a specific model would be beneficial:
  - Fetch current models from https://docs.anthropic.com/en/docs/about-claude/models/overview
  - Use latest Haiku for simple, repetitive tasks (formatting, basic validation)
  - Use latest Sonnet for standard development tasks (default - usually best choice)
  - Use latest Opus for complex reasoning (architectural analysis, planning)
  - **PREFER LATEST**: Always use newest versions (Opus 4.1 over 3, latest Sonnet over 3.5, etc.)
  - **WARNING**: Check token limits in fetched documentation
  - **RECOMMENDATION**: Usually best to omit and inherit session model
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

1. **Create task template(s)** in the `tasks/` directory:
   - Name: `[command-name]-analyzer.md` (use "analyzer" for read-only tasks)
   - Purpose: Handle specific analysis subtasks in isolation
   - Content: Task-specific system prompt without YAML frontmatter

2. **Update command to orchestrate analysis**:
   ```markdown
   For analyzing multiple [targets]:
   - Read task template: Read('tasks/[command-name]-analyzer.md')
   - Use Task tool with subagent_type: 'general-purpose' and template as prompt
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

## 7. Create and Validate the Command

**CRITICAL: Commands are USER INPUT TEMPLATES**
- Write prompts in **second person** ("You should...", "Analyze this...", "Please review...")
- Commands are injected AS IF THE USER TYPED THEM
- They are NOT system prompts that define agent identity
- Write as instructions TO Claude, not AS Claude

Generate the command file that:
- Uses directive language TO the AI agent ("Review this", "Generate a", "Analyze the")
- Includes any necessary context or constraints
- Properly handles arguments if applicable
- Follows the pattern of existing commands in the commands folder
- Incorporates parallelization strategy if applicable

### Avoid Verbosity - Keep Commands Concise:
- **Be direct**: Use imperative statements, not explanatory prose
- **Skip obvious explanations**: Don't explain WHY to do something unless it's non-obvious
- **Use bullet points**: Replace paragraphs with structured lists
- **Remove redundancy**: Say each thing once, clearly
- **Focus on actions**: Commands are instructions, not tutorials
- **Good**: "1. Read file 2. Extract functions 3. Generate tests"
- **Bad**: "First, we need to read the file to understand its contents. Then, after we've read it, we should carefully extract all the functions because we need to know what functions exist. Finally, once we have the functions, we can generate tests for them."

### Automatic Validation
Use the Task tool to validate your draft:

```markdown
template = Read('tasks/create-command-validator.md')
Task(subagent_type: 'general-purpose', prompt: template + draft)
```

Apply validation feedback automatically to optimize the command.

**Don't show drafts** - proceed directly to creating the final command file.

## 8. Save the Command

Immediately save the command:
- Write to `.claude/commands/` (project-local by default)
- Create any necessary subdirectories for namespaced commands
- If task templates were created, save them to `.claude/tasks/`
- Confirm successful creation with a brief summary

## 9. Handle User Feedback (If Any)

Only if the user provides feedback after creation:
- Make requested adjustments
- Update the saved file
- Confirm changes made

## Important Notes

### Command Design Principles:
- **Write commands as USER PROMPTS**: Use second-person instructions ("You should", "Please analyze")
- Commands are injected into conversation AS IF THE USER TYPED THEM
- Keep prompts clear and actionable with directive language
- Include specific instructions about output format when relevant
- Consider edge cases and include appropriate handling
- **Automate processes, not practices**: Focus on well-defined tasks with objective success criteria

### Context Management:
- **CLAUDE.md interaction**: Commands should respect project conventions in CLAUDE.md
- **Avoid "junk drawer" anti-pattern**: Don't add conflicting or untested instructions to CLAUDE.md
- **Session hygiene**: For long workflows, recommend using `/clear` between major phases
- **Context awareness**: Remember that subagents start with fresh context (good for parallel tasks)

### Validation Integration:
- **Parallel Validation**: Use validation task templates for efficient quality assurance
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

1. **Requirements Analysis**: Use Task tool with validation templates to analyze requirements
2. **Component Creation**: Create main command first, then create task templates if needed for parallelization
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
