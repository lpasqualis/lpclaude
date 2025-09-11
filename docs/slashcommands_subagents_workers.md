# Component Selection Rules: Subagents vs Workers vs Slash Commands

## Introduction

This document provides definitive guidance for choosing between three types of Claude Code components when extending functionality. Making the right choice is critical for performance, context management, and user experience.

### What This Document Covers
- Clear definitions of each component type
- Decision criteria for selecting the appropriate component
- Refactoring patterns when you need to change your approach
- Best practices for minimizing context overhead

### Key Definitions

**AI Components**: Subagents and workers that execute with their own fresh context windows, separate from Main Claude's conversation context.

**Subagent**: A Claude Code native AI assistant that users can invoke conversationally (e.g., "check security") or that triggers automatically on keywords. Defined with YAML frontmatter. Always consumes context space.

**Worker**: A non-native AI assistant invoked only programmatically by slash commands via the Task tool. Pure prompt files with no YAML frontmatter. Zero context overhead when not in use.

**Slash Command**: A user-triggered command (e.g., `/git:commit`) that orchestrates operations and coordinates AI components. Runs in Main Claude's context. Can invoke subagents and workers but cannot call other slash commands.

**Context Overhead**: The memory consumed by subagent YAML frontmatter (name, description, trigger keywords) that remains loaded at all times, even when the subagent isn't being used.

**Task Tool**: The mechanism slash commands and Main Claude use to invoke subagents and workers. Limited to 10 concurrent invocations system-wide.

## Critical Distinction: Subagents vs Workers

**THE KEY DIFFERENCE**: 
- **Subagents**: Claude-code native concept. Users can invoke them conversationally, and they trigger automatically on keywords. Their activation rules (name, description, and trigger keywords in YAML frontmatter) consume context space at ALL times. Use only when auto-triggering or conversational access is essential.
- **Workers**: Not a Claude-code native concept. Can ONLY be invoked programmatically by slash commands via Task tool. Perfect for parallel processing within workflows. Zero context overhead since they have no YAML frontmatter loaded into memory.

**DESIGN PRINCIPLE**: Prefer slash commands and workers over subagents whenever possible to minimize context overhead. Only use subagents when auto-triggering or conversational access provides clear user value.

**BOTH have**:
- Specialized domain expertise
- Fresh, dedicated context windows
- Access to tools (except Task)
- Ability to perform complex analysis
- Can run in parallel (up to 10 concurrent Task invocations total system-wide, shared across all subagents/workers)

## Quick Decision Matrix

| Question | Subagent | Worker | Slash Command |
|----------|----------|--------|---------------|
| Needs to orchestrate multiple operations? | ❌ | ❌ | ✅ |
| Should trigger automatically on keywords? | ✅ | ❌ | ❌ |
| User can invoke conversationally? | ✅ | ❌ | ❌ |
| Consumes context space when idle? | ✅ | ❌ | ❌ |
| Justified despite context overhead? | ✅ | ❌ | ❌ |
| Needs specialized domain expertise? | ✅ | ✅ | ❌ |
| Runs in fresh context window? | ✅ | ✅ | ❌ |
| Can be executed in parallel? | ✅ | ✅ | ❌ |
| Needs to coordinate other AI components? | ❌ | ❌ | ✅ |

## Decision Guidelines

### The Core Decision: How It's Invoked
- **User conversational access needed** → Subagent required
- **Auto-triggering on keywords needed** → Subagent only option  
- **Called only by slash commands** → Worker (saves context)
- **Parallel processing in workflows** → Worker optimal
- **Orchestration of other components** → Slash command required

### When to Extract vs Inline (Within Slash Commands)
- **Extract to Worker**: When parallel execution is beneficial, or when the logic is reusable across multiple commands
- **Keep Inline**: When the logic is sequential, command-specific, and doesn't benefit from parallelization
- **Worker Complexity**: Workers can be simple utilities or complex domain experts - complexity doesn't determine worker vs inline

### Context Cost Evaluation
- **Always Justified**: When auto-triggering or user conversational access is required
- **Acceptable Overhead**: <100 lines of YAML frontmatter
- **Consider Carefully**: 100-200 lines of YAML - ensure the user interaction truly needs it
- **Likely Excessive**: >200 lines of YAML - consider if the component design is too complex

### Activation Pattern Examples
- **Security Keywords**: "vulnerability", "security", "hack", "exploit", "hardcoded"
- **Documentation Keywords**: "docs", "documentation", "README", "outdated", "audit"
- **Performance Keywords**: "slow", "optimize", "performance", "bottleneck"
- **Delegation Keywords**: "ask", "delegate", "GPT", "Gemini", "external model"

## Component Type Definitions

Now that we understand the key differences and decision thresholds, let's examine each component type in detail:

### Subagents
**Definition**: Specialized AI assistants with domain expertise that can be invoked conversationally or proactively

**Technical Constraints**:
- Cannot use Task tool (framework-filtered)
- Cannot execute slash commands
- Stateless - single invocation model
- Fresh context window per invocation
- Invoked BY Main Claude or slash commands using Task tool with `subagent_type: <name>`, OR conversationally (automatically) by user
- Located in `.claude/agents/` directory
- Require YAML frontmatter with name, description, tools
- Can be executed in parallel (shares the 10 total Task limit)

**CRITICAL COST**: Activation rules (YAML frontmatter including name, description, and trigger keywords) loaded into Main Claude's context at ALL times, consuming memory even when not in use

### Workers
**Definition**: Specialized AI assistants with domain expertise that can ONLY be invoked programmatically via the Task tool

**Technical Constraints**:
- Cannot use Task tool
- Cannot execute slash commands
- Fresh context window per invocation (same as subagents)
- Can have deep domain expertise (same as subagents)
- Invoked BY Main Claude or slash commands using Task tool with `subagent_type: 'general-purpose'` and a prompt pointing to the worker file
- Often created to parallelize work that a slash command needs to do
- Can be located anywhere (Claude Code doesn't care)
  - **Convention for project-specific workers**: Place in `workers/` or `workers/{parent-command}-workers/` subdirectories
  - **Convention for global workers**: Place in `~/.claude/workers/` or `~/.claude/workers/{parent-command}-workers/`
  - Location depends on scope: project-specific vs globally available
- Pure prompts - no YAML frontmatter
- Can be executed in parallel (shares the 10 total Task limit)

**CRITICAL BENEFIT**: Zero context overhead - not loaded until actually invoked

### Slash Commands
**Definition**: User-triggered orchestration scripts that coordinate operations and AI components

**Technical Constraints**:
- Can use Task tool to invoke subagents and/or workers
- Cannot execute other slash commands
- Run in Main Claude's context
- Located in `commands/` directory
- Require YAML frontmatter with allowed-tools
- Triggered by user via `/command-name`
- Claude sees them as commands that the user typed

## Decision Rules

Based on these technical constraints and capabilities, here are the specific rules for choosing between component types:

### Rule 1: Use a SUBAGENT when:

1. **User Interaction Required**
   - Users need to invoke it directly in conversation
   - Should trigger automatically on keywords
   - Natural language invocation expected
   - Example: `delegate` responding to "ask GPT-4"

2. **Automatic Triggering Essential**
   - Must respond to keywords without explicit invocation
   - Proactive assistance is core to the feature
   - Pattern recognition triggers defined in description field
   - Example: `hack-spotter` auto-triggers on "security", "vulnerability", "hack"
   - **Note**: This is ONLY possible with subagents, never workers

3. **Context Cost Justified**
   - **Auto-triggering needed**: Must respond to keywords automatically
   - **User conversational access**: Users expect to invoke it naturally
   - **Critical proactive assistance**: Security, validation, or safety features
   - **Context threshold**: YAML frontmatter <100 lines is acceptable overhead
   - Example: `hack-spotter` for security analysis (auto-triggers on security keywords)

4. **Cannot Be Deferred to Command**
   - Needs immediate, contextual response
   - User shouldn't have to explicitly invoke
   - Natural flow of conversation
   - Example: `completion-verifier` for validation claims

### Rule 2: Use a WORKER when:

1. **Programmatic Invocation Only**
   - Called exclusively by slash commands
   - No user conversational access needed
   - No auto-triggering on keywords required
   - Example: `git-commit-workers/analyzer.md` invoked only by /git:commit command

2. **Parallel Processing in Workflows**
   - Multiple tasks to execute concurrently
   - Slash command needs to spawn parallel analyses
   - Batch operations on different items
   - Example: Multiple specialized analyzers running simultaneously

3. **Context Conservation Critical**
   - **No user interaction needed**: Only called by slash commands
   - **No auto-triggering required**: Explicit invocation only
   - Would waste context as subagent (YAML loaded but never triggered by users)
   - Example: Specialized validators used only by git-commit command

4. **Slash Command Component**
   - Exists solely to support slash command workflows
   - Never invoked outside of slash commands
   - Users don't know or care it exists
   - Example: Security scanners in commit workflow

### Rule 3: Use a SLASH COMMAND when:

1. **Orchestration Required**
   - Coordinate multiple subagents/workers
   - Sequential workflow management
   - Conditional logic between steps
   - Example: `/git:commit-and-push`

2. **User Control Essential**
   - Explicit triggering needed
   - User parameters required
   - Interactive workflow
   - Example: `/implan:create`

3. **Complex Multi-Step Process**
   - Multiple operations to coordinate
   - State management between steps
   - Tool usage plus AI coordination
   - Example: `/docs:capture-session`

4. **Context Modification**
   - Changes to current working context
   - File system operations
   - Environment setup
   - Example: `/simplify`

5. **Do not need to be invoked by other slash commands**
   - Slash commands cannot execute slash commands

## Anti-Patterns (What NOT to Do)

### ❌ DON'T Use a Subagent When:
- You need to orchestrate multiple operations → Use slash command
- Users will never invoke it conversationally → Use worker to save context
- Only needed for programmatic workflows → Use worker
- Task requires Task tool → Must use slash command
- No auto-triggering or user interaction needed → Use worker to save context

### ❌ DON'T Use a Worker When:
- Users need conversational access → Use subagent
- Automatic triggering required → Use subagent
- Complex orchestration needed → Use slash command
- Proactive assistance needed → Use subagent
- No benefit from parallel execution or reusability → Consider inline execution in slash command

### ❌ DON'T Use a Slash Command When:
- Task should trigger automatically → Use subagent (slash commands require explicit invocation)
- Users need conversational/natural language invocation → Use subagent
- Needed programmatically by other slash commands → Use worker or subagents

## Refactoring Guidelines

### When You Realize You Chose Wrong

#### Subagent → Worker
**Discovery**: Subagent is never actually triggered by users - only called programmatically
**Why Refactor**: Save context overhead for something never used conversationally
**Process**:
1. Track usage - confirm no user ever invokes it directly
2. Remove YAML frontmatter (keeping the expertise intact)
3. Move to `workers/` directory
4. Update calling commands to use `subagent_type: 'general-purpose'` with prompt path
**Benefit**: Frees up context space with zero functionality loss

#### Worker → Subagent  
**Discovery**: Users keep asking "how do I run X" about a worker capability
**Why Refactor**: Users need direct access to this functionality
**Process**:
1. Create YAML frontmatter with name and description
2. Add trigger keywords if auto-triggering desired
3. Move to `agents/` directory
**Cost**: Permanent context overhead - ensure it's truly needed

#### Extracting Workers from Slash Commands
**Discovery**: Parts of a slash command could run in parallel
**Why Refactor**: Improve performance through parallelization
**Process**:
1. Identify independent operations within the command
2. Extract each to a worker file in `workers/{command}-workers/`
3. Update command to invoke workers in parallel via Task tool
4. Keep orchestration logic in the command
**Benefit**: Faster execution, cleaner separation of concerns

#### Subagent → Slash Command (Preferred When Possible)
**Discovery**: Subagent doesn't actually need auto-triggering or conversational access
**Why Refactor**: Save context overhead - slash commands don't consume memory when idle
**Common Cases**:
- Subagent rarely triggers automatically in practice
- Users are fine with explicit `/command` invocation
- Feature needs Task tool for orchestration
- Auto-triggering causes more false positives than value
**Process**:
1. Move to `commands/` directory
2. Add `allowed-tools` to frontmatter if needed
3. Remove auto-triggering description
4. Document the `/command` syntax for users
**Benefit**: Frees context space while maintaining full functionality with explicit invocation

#### Merging Multiple Workers
**Discovery**: Workers are always called together in the same pattern
**Why Refactor**: Reduce complexity and Task invocation overhead
**Process**:
1. Combine worker prompts into single comprehensive worker
2. Update calling commands to use single Task invocation
**Note**: Only merge if they're truly always used together

#### Splitting an Overloaded Subagent
**Discovery**: Subagent description has too many trigger patterns, causing false positives
**Why Refactor**: Reduce unintended activations
**Process**:
1. Identify distinct capability groups
2. Create focused subagents with specific trigger patterns
3. Each subagent should have a clear, narrow purpose
**Benefit**: More predictable auto-triggering behavior

## Examples

### Good Subagent Example
```yaml
name: hack-spotter
description: Expert code security reviewer... MUST BE USED PROACTIVELY
tools:
  - Read
  - Grep
  - WebFetch
```
**Why**: Specialized expertise, automatic triggering, self-contained

### Good Worker Example
```markdown
# analyzer.md
You are an expert code quality analyst specializing in identifying:
- Security vulnerabilities
- Performance bottlenecks  
- Code style violations
- Architectural anti-patterns

Analyze the provided code section...
```
**Why**: Deep expertise, never needs user access, saves context overhead

### Good Slash Command Example
```yaml
allowed-tools:
  - Task
  - Bash
  - Read
---
Coordinate the git commit process by:
1. Running security checks
2. Analyzing changes with workers
3. Creating commit with proper message
```
**Why**: Orchestrates multiple operations, needs user trigger, complex workflow

## Component Interaction Patterns

### Pattern 1: Slash Command + Workers
```
/command → spawns multiple workers in parallel → aggregates results
```
Use when: Batch processing with coordination
**Note**: Maximum 10 parallel Tasks system-wide

### Pattern 2: Slash Command + Subagent
```
/command → invokes specialized subagent → processes result
```
Use when: Need expertise within workflow

### Pattern 3: Main Claude + Subagent
```
User mentions keyword → subagent auto-triggers → provides expertise
```
Use when: Proactive assistance needed

### Pattern 4: Slash Command + Mixed
```
/command → workers (parallel) + subagent (sequential) → complete
```
Use when: Complex workflow with varied needs

## Final Checklist for Component Selection

Before creating a component, answer these questions:

1. **Who needs to invoke it?**
   - Users conversationally → Subagent (accept context cost)
   - Users via explicit command → Slash command
   - Only other components programmatically → Worker (save context)
   - System automatically based on keywords → Subagent only

2. **What's the context cost/benefit?**
   - Needs auto-triggering → Subagent (accept the cost)
   - User conversational access → Subagent (cost justified)
   - Programmatic-only invocation → Worker (save context)
   - Slash command parallelism → Worker optimal

3. **What does it need to do?**
   - Orchestrate multiple operations → Slash command only
   - Provide expertise with user access → Subagent
   - Provide expertise without user access → Worker
   - Support parallel execution in workflows → Worker

4. **How does it execute?**
   - Parallel with siblings (within 10 Task limit) → Worker
   - Sequential with coordination → Slash command
   - Independent with user triggers → Subagent
   - Independent programmatic only → Worker

5. **What tools does it need?**
   - Task tool → Slash command only
   - Other tools → Any component type
   - No tools → Worker preferred for efficiency