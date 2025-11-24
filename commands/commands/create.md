---
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
- Whether arguments are needed (all-arguments via `$ARGUMENTS` or positional via `$1`, `$2`, etc.)
- Whether dynamic context is needed (bash execution with exclamation-backtick syntax, file references with @ prefix)
- **Whether to exclude from SlashCommand tool** - Evaluate based on:
  - **Include (omit field)** if: Command might be useful for Claude to invoke automatically, general-purpose workflow, reusable across contexts
  - **Exclude (add `disable-model-invocation: true`)** if: Maintenance/admin only, rarely needed programmatically, very long description consuming excessive context, highly specialized manual-only operation

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
description: Brief description of functionality (defaults to first line of prompt if omitted)
argument-hint: [specific arguments expected]
allowed-tools: [appropriate tool grouping]
---

[Concise, directive instructions]

## Arguments
Use $ARGUMENTS for all arguments, or $1, $2, $3 for individual positional parameters.

## Dynamic Context (optional)
- Bash execution: Exclamation mark followed by backtick-wrapped command
- File references: @path/to/file

[Any constraints or output format requirements]
```

**Note**: Command name is derived from the filename (e.g., `optimize.md` creates `/optimize`), not from frontmatter.

### Optional Frontmatter Fields:
- **disable-model-invocation: true** - Exclude from SlashCommand tool to save context
  - Use when: Command is rarely needed programmatically
  - Use when: Command is maintenance/admin only
  - Use when: Command has a very long description that would consume excessive context
- **model: [model-id]** - Use specific model (e.g., `claude-3-5-haiku-20241022` for simple operations)
  - Default: Inherits from conversation
  - Generally prefer the default unless cost optimization is critical

### Argument Handling:

**All Arguments Pattern (`$ARGUMENTS`)**:
- Captures everything after the command name as a single string
- Use when: Arguments are flexible natural language instructions
- Example: `/fix-issue $ARGUMENTS` → `/fix-issue refactor auth module` → `$ARGUMENTS = "refactor auth module"`

**Positional Arguments Pattern (`$1`, `$2`, `$3`)**:
- Individual space-separated arguments
- Use when: Specific structured parameters are needed
- Example: `/review-pr $1 priority $2` → `/review-pr 456 high` → `$1 = "456"`, `$2 = "high"`
- Better for commands requiring specific roles for each parameter

### Dynamic Context Features:

**Bash Command Execution (exclamation mark):**
- Execute bash commands before Claude sees the prompt
- Syntax: Exclamation mark followed by backtick, then command, then closing backtick
- Output is included as static text in the prompt
- **Required**: Must include appropriate bash commands in `allowed-tools`
- **Limitation**: Each command runs in isolation (variables don't persist)
- Example:
  ```markdown
  ---
  allowed-tools: Bash(git status:*), Bash(git diff:*)
  ---

  Current status: [Use exclamation-backtick syntax with: git status]
  Recent changes: [Use exclamation-backtick syntax with: git diff HEAD]
  ```

**File References (`@`)**:
- Include file contents directly in the prompt
- Syntax: `@path/to/file`
- Paths can be relative or absolute
- Directory references show listings, not contents
- Files are read at execution time (always fresh)
- Example:
  ```markdown
  Review the implementation in @src/auth.js
  Compare @old/version.js with @new/version.js
  ```

**Extended Thinking**:
- Commands can trigger extended thinking by including thinking-mode keywords
- Claude will engage deeper reasoning for complex problems
- No special syntax required - thinking keywords naturally trigger the mode

## Implementation Steps

1. **Analyze Requirements**: Determine command type and scope
2. **Evaluate SlashCommand Tool Inclusion**: Decide whether to add `disable-model-invocation: true` based on command purpose
3. **Generate YAML Frontmatter**: Include all required fields with logical tool groupings and the disable-model-invocation decision
4. **Write Command Body**: Use concise, directive language with clear steps
5. **Add Argument Placeholder**: Use `$ARGUMENTS` or positional parameters for customization
6. **Validate Draft**: Use existing validation task template if needed
7. **Create Command File**: Save in appropriate directory
8. **Report Creation**: Provide summary including:
   - Command name and location
   - Tools allowed
   - **SlashCommand tool availability decision and reasoning**
   - Key features of the command

## Validation Integration

For complex commands requiring validation:
```markdown
template = Read('workers/commands-create-workers/command-validator.md')
Task(subagent_type: 'general-purpose', prompt: template + draft_command)
```

Apply validation feedback to optimize the command before saving.

## Worker Task Organization

If creating parallel execution workers for a command:
- Store worker templates in subdirectories based on command format:
  - Simple commands: `workers/{command-name}-workers/`
  - Namespaced commands: `workers/{namespace}-{name}-workers/`
- Examples:
  - `/optimize` workers go in `workers/optimize-workers/`
  - `/commands:optimize` workers go in `workers/commands-optimize-workers/`
- This keeps worker tasks organized by their parent command

## Best Practices

- **Be autonomous**: Create immediately with reasonable assumptions
- **Stay focused**: One clear purpose per command
- **Use directive language**: "Analyze", "Generate", "Review"
- **Include argument placeholders**: Use `$ARGUMENTS` or `$1`, `$2`, etc. for user customization
- **Validate early**: Check against best practices during creation
- **Context awareness**: Consider adding `disable-model-invocation: true` for:
  - Test commands that are only run manually
  - Maintenance commands that don't need automation
  - Commands with very long descriptions
  - Project-specific commands unlikely to be called by Claude

## User's Command Request

$ARGUMENTS
