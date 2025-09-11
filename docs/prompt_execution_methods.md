# Choosing a Prompting Strategy

## Core Concepts

### What is Claude Code?
Claude Code is an AI-powered development assistant that can understand and execute various types of prompts and commands. It operates through different execution contexts and delegation mechanisms.

### Key Terms
- **Main Claude**: The primary AI instance you interact with directly in your conversation
- **Context window**: The memory space containing the conversation history and loaded information
- **Fresh context**: A new, separate memory space with no access to the main conversation
- **Task tool**: A mechanism that allows Claude to delegate work to separate AI instances

## Background

  Claude Code offers multiple ways to deliver and execute prompts:
  - **Direct execution**: Interactive user prompts processed by Main Claude
  - **Autonomous execution**: Main Claude deciding what to do next, invoking subagents and tasks as needed
  - **Persistent shortcuts**: Slash commands for reusable user-triggered prompts
  - **Fresh context delegation**: The Task tool executes prompts in separate context windows
  - **Specialized delegates**: Subagents (auto-triggered or Claude-invoked) and workers 
    (slash command-invoked) are conventions built on top of the Task tool

## The Decision Tree
```
 START: How will this prompt be used?
    │
    ├─> Will it be reused across multiple sessions?
    │   ├─> NO → INTERACTIVE USER PROMPT
    │   └─> YES → How will it be triggered?
    │       ├─> User types a command → SLASH COMMAND
    │       ├─> By slash command(s) programmatically
    │       │    └─> Reusable across commands OR needs parallel execution?
    │       │         ├─> YES → WORKER
    │       │         └─> NO → INLINE PROMPT IN THE SLASH COMMAND
    │       ├─> By Main Claude programmatically → SUBAGENT
    │       └─> Automatically on keywords → SUBAGENT
    │
    └─> Default → INTERACTIVE USER PROMPT
```

## Ways to execute Prompts

### 1. INTERACTIVE USER PROMPT
**What they are**: Commands typed by the user
- **Invocation**: user types it
- **Context**: Run in Main Claude's conversation context
- **Superpowers**: All powerful, it all starts here
- **Limitations**: Simple, one-time use
- **Location**: Not stored anywhere

### 2. MAIN CLAUDE AGENT
**What is it**: Main Claude prompting itself and deciding what to do next
- **Invocation**: The LLM working on a problem
- **Context**: Run in Main Claude's conversation context
- **Superpowers**: 
  - Main LLM functionality
  - Has access to tools
- **Limitations**: Cannot execute slash commands and will not automatically trigger workers (but could, in theory)

### 3. TASK
**What they are**: A tool that can execute a system prompt in a separate, fresh context
- **Invocation**: From interactive user prompts, slash commands, or by the main Claude agent
- **Context**: Fresh, dedicated context window per invocation (same as subagents)
- **Superpowers**: 
  - Native Claude Code tool
  - Can run in parallel with other tasks and has no memory overhead when not in use. 
  - It is the mechanism that invokes subagents and workers.
- **Limitations**: Cannot invoke other tasks (including workers and subagents) or slash commands
- **Location**: `workers/` directory (by convention)

### 4. SLASH COMMAND
**What they are**: 
   - User-triggered, file-persistent reusable prompts
   - Composed by a series of IN-LINE prompts.
- **Invocation**: `/[namespace:]command-name` by user using an interactive user prompt
- **Context**: Run in Main Claude's conversation context
- **Superpowers**: 
  - Can orchestrate multiple subagents/workers/tasks in parallel
  - Can be placed in a namespace for ease of organization
  - Can specify which model to use
  - Can restrict what tools are available to it
- **Limitations**: Cannot invoke another slash command, and can only be invoked by a user as an interactive user prompt
- **Location**: `commands/[namespace]` folder(s)

### 5. SUBAGENT
**What they are**: Specialized AI assistants that users trigger automatically on keywords or main Claude can invoke as needed to solve problems. 
- **Invocation**: Auto-trigger on users keywords or invoked by Main Claude based on need. Behind the curtains, it runs using a Task tool.
- **Context**: Fresh, dedicated context window per invocation
- **Superpower**: 
  - Native Claude Code concept
  - Proactive assistance without explicit commands, known by main Claude as a tool at its disposal
  - Can specify which model to use
  - Can restrict what tools are available to it
- **Limitations**: Cannot invoke other tasks, workers, subagents or slash commands
- **Cost**: YAML frontmatter loaded into the context at ALL times
- **Location**: `.claude/agents/` directory

### 6. WORKER  
**What they are**: Specialized AI assistants that is invoked programmatically by slash commands using the Task tool
- **Invocation**: Only via Task tool from slash commands
- **Context**: Fresh, dedicated context window per invocation (same as subagents)
- **Superpower**: Can run in parallel with other tasks and has no memory overhead when not in use
- **Limitations**: 
  - Not a native Claude Code concept.
  - Cannot invoke other tasks, workers, subagents or slash commands. 
  - Claude won't choose to run one as needed like it does for subagents.
- **Location**: `workers/` directory (by convention)

## Technical Constraints

### Execution Hierarchy

```
User Prompts
├─> Can invoke: subagents, slash commands
├─> Can use: Task tool
└─> Runs in: main conversation context

Main Claude
├─> Can invoke: subagents
├─> Can use: Task tool
└─> Runs in: main conversation context

Slash Commands  
├─> Can invoke: subagents, workers
├─> Cannot invoke: other slash commands
├─> Can use: Task tool (up to 10 concurrent)
└─> Runs in: main conversation context

Subagents/Workers
├─> Invoked using the Task tool
├─> Cannot use: Task tool
├─> Cannot invoke: subagents or workers (because no Task tool access)
├─> Cannot execute: slash commands
└─> Runs in: fresh context window
└─> Stateless: single invocation only
```

### Key Framework Rules
- **Task tool limit**: Maximum 10 concurrent Task invocations system-wide
- **No recursive delegation**: Components invoked via Task cannot use Task themselves
- **Changes require restart**: Both agents and slash commands load at startup only

## Common Anti-Patterns

### ❌ Using a subagent when only slash commands call it
**Problem**: Wastes context memory for something users never invoke
**Solution**: Convert to worker

### ❌ Using a worker when users need conversational access
**Problem**: While technically possible, users won't invoke workers directly
**Solution**: Convert to subagent (accept the context cost)

## Refactoring Decision Points

### Subagent → Worker
**When**: Only slash commands need to invoke it AND it needs to run in parallel with other operations AND needs to be reusable across multiple slash commands 
**Benefit**: Frees context space with zero functionality loss

### Worker → Subagent
**When**: It would be useful for a user or the main agent to trigger it outside of a slash command
**Cost**: Permanent context overhead

### Subagent → Slash Command
**When**: Auto-triggering causes more false positives than value
**Benefit**: User has explicit control, saves context

### Inline → Worker
**When**: Inline prompts within slash command could run in parallel with other operations AND it needs to be shared by multiple slash commands
**Benefit**: Faster execution through parallelization, reusability and single source of truth
