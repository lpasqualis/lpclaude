# Choosing a Prompting Strategy

## Key Discoveries (Updated with v1.0.123+ Testing)

### The SlashCommand Tool Changes Everything
Testing has revealed that the SlashCommand tool (introduced in v1.0.123) is universally available to ALL execution contexts:
- **Main Claude** can invoke slash commands programmatically
- **Slash Commands** can invoke other slash commands (including recursively)
- **Subagents** can invoke slash commands from their fresh contexts
- **Workers** can invoke slash commands, enabling them to orchestrate complex operations

### Critical Findings from Testing
1. **No Circular Dependency Protection**: SlashCommand invocations can create infinite loops
2. **Cross-Context Bridge**: Subagents/Workers in fresh contexts can trigger main-context operations via slash commands
3. **Complex Orchestration Possible**: Workers can invoke commands that create other workers
4. **Manual Safeguards Required**: Implement recursion counters, execution flags, or timeouts

### What This Means
The universal availability of SlashCommand tool enables orchestration patterns previously thought impossible:
- Workers can work around their Task tool limitation by invoking slash commands
- Subagents can influence the main conversation despite being in fresh contexts
- Recursive and self-modifying command structures are possible
- Complex multi-level delegation chains can be constructed

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
  - Has access to all tools including SlashCommand tool (v1.0.123+)
  - Can execute slash commands programmatically
- **Limitations**: Will not automatically trigger workers (though could via slash commands)

### 3. TASK
**What they are**: A tool that can execute a system prompt in a separate, fresh context
- **Invocation**: From interactive user prompts, slash commands, or by the main Claude agent
- **Context**: Fresh, dedicated context window per invocation (same as subagents)
- **Superpowers**: 
  - Native Claude Code tool
  - Can run in parallel with other tasks and has no memory overhead when not in use. 
  - It is the mechanism that invokes subagents and workers.
- **Limitations**: Cannot invoke other tasks (including workers and subagents) directly, but CAN execute slash commands via SlashCommand tool
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
- **Limitations**: Can only be invoked by a user as an interactive user prompt (though can invoke other slash commands via SlashCommand tool)
- **Cost**: Command metadata (name, args, description) consumes context tokens via SlashCommand tool
- **Opt-out**: Add `disable-model-invocation: true` to frontmatter to exclude from SlashCommand tool
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
- **Limitations**: Cannot invoke other tasks, workers, or subagents (no Task tool), but CAN execute slash commands via SlashCommand tool
- **Cost**: YAML frontmatter loaded into the context at ALL times
- **Location**: `.claude/agents/` directory

### 6. WORKER  
**What they are**: Specialized AI assistants that is invoked programmatically by slash commands using the Task tool
- **Invocation**: Only via Task tool from slash commands
- **Context**: Fresh, dedicated context window per invocation (same as subagents)
- **Superpower**: Can run in parallel with other tasks and has no memory overhead when not in use
- **Limitations**: 
  - Not a native Claude Code concept.
  - Cannot invoke other tasks, workers, or subagents (no Task tool), but CAN execute slash commands via SlashCommand tool. 
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
├─> Can invoke: subagents, workers, other slash commands (via SlashCommand tool)
├─> ⚠️ No circular dependency protection
├─> Can use: Task tool (up to 10 concurrent)
└─> Runs in: main conversation context

Subagents/Workers
├─> Invoked using the Task tool
├─> Cannot use: Task tool
├─> Cannot invoke: subagents or workers (no Task tool)
├─> Can execute: slash commands via SlashCommand tool
└─> Runs in: fresh context window
└─> Stateless: single invocation only
```

### Key Framework Rules
- **Task tool limit**: Maximum 10 concurrent Task invocations system-wide
- **No recursive Task delegation**: Components invoked via Task cannot use Task themselves
- **SlashCommand tool is universal**: Available to ALL execution levels (Main Claude, Slash Commands, Subagents, Workers)
- **No circular dependency protection**: SlashCommand invocations can create infinite loops - manual safeguards required
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

## The SlashCommand Tool (v1.0.123+)

### Context Management
The SlashCommand tool automatically loads slash command metadata into context:
- **What's loaded**: Command name, argument-hint, and description for each command
- **Character budget**: Default 15,000 chars (configurable via SLASH_COMMAND_TOOL_CHAR_BUDGET)
- **When budget exceeded**: Only a subset of commands will be available to Claude
- **Monitor usage**: Use `/context` to see SlashCommand tool token consumption
- **Opt-out options**:
  - Per-command: Add `disable-model-invocation: true` to frontmatter
  - Globally: Use `/permissions` to deny SlashCommand tool entirely

### Overview
The SlashCommand tool enables programmatic invocation of slash commands from any execution context. This powerful capability was introduced in Claude Code v1.0.123 and fundamentally expands orchestration possibilities.

### Universal Availability
**IMPORTANT**: The SlashCommand tool is available to ALL execution levels:
- ✅ Main Claude can invoke slash commands programmatically
- ✅ Slash Commands can invoke other slash commands
- ✅ Subagents can invoke slash commands
- ✅ Workers can invoke slash commands

This universal access enables complex orchestration patterns previously impossible.

### Circular Invocation Capabilities
Testing has confirmed that circular invocation chains are fully supported:
- Slash Command → Task → Worker → SlashCommand → Slash Command (and repeat)
- Workers/Subagents can invoke slash commands that create new workers/subagents
- No built-in loop protection exists - manual safeguards are required

### Tested Execution Chains

#### Chain 1: Simple Nested Invocation
```
Main Claude
└─> /command1 (via SlashCommand tool)
    └─> /command2 (via SlashCommand tool)
        └─> /command3 (via SlashCommand tool)
```
**Result**: ✅ Works without limits

#### Chain 2: Task-SlashCommand Interleaving
```
Slash Command
└─> Task tool → Worker
    └─> SlashCommand tool → Slash Command
        └─> Task tool → Another Worker
            └─> SlashCommand tool → Another Slash Command
```
**Result**: ✅ Works - workers can invoke commands that create workers

#### Chain 3: Circular Dependencies
```
/test-slash-command-l2
└─> /test-slash-command-tool
    └─> /test-slash-command-l2 (circular)
        └─> /test-slash-command-tool (continues infinitely)
```
**Result**: ⚠️ Works but creates infinite loop - no automatic protection

### Orchestration Patterns

#### Pattern 1: Delegation Chain
Workers can delegate to slash commands for operations they cannot perform directly:
```
Worker (no Task tool access)
└─> SlashCommand tool → /orchestrator-command
    └─> Task tool → Multiple parallel workers
```

#### Pattern 2: Recursive Processing
Slash commands can recursively process data structures:
```
/process-tree node1
└─> Process node1
└─> SlashCommand tool → /process-tree child1
└─> SlashCommand tool → /process-tree child2
```

#### Pattern 3: Cross-Context Communication
Subagents in fresh contexts can trigger main-context operations:
```
Subagent (fresh context)
└─> SlashCommand tool → /update-main-context
    └─> Executes in main conversation context
```

### Safety Considerations

#### Circular Dependency Prevention
Since there's no built-in protection, implement manual safeguards:

1. **Recursion Counters**: Pass depth/level as arguments
```markdown
---
argument-hint: [recursion-level]
---
If $ARGUMENTS >= 3, stop execution
```

2. **Execution Flags**: Use context markers
```markdown
Check if already processing: look for "PROCESSING_X" marker
If found, stop to prevent re-entry
```

3. **Timeout Mechanisms**: Limit execution time
```markdown
Track start time
If elapsed > threshold, halt execution
```

#### Best Practices
- Always implement recursion limits for commands that invoke themselves
- Document circular dependency risks in command descriptions
- Use explicit termination conditions
- Consider using execution state tracking
- Test circular invocation paths with limits

### Advanced Capabilities

#### Multi-Level Orchestration
Combine all tools for complex workflows:
```
Main Claude
├─> Task → Subagent A (analyze)
├─> SlashCommand → /process (orchestrate)
│   ├─> Task → Worker 1 (parallel)
│   ├─> Task → Worker 2 (parallel)
│   └─> SlashCommand → /validate
└─> Task → Subagent B (finalize)
```

#### Dynamic Command Composition
Slash commands can dynamically invoke others based on conditions:
```
/adaptive-processor
├─> Evaluate input type
├─> If type A: SlashCommand → /processor-a
├─> If type B: SlashCommand → /processor-b
└─> If type C: SlashCommand → /processor-c
```

## Testing These Capabilities

### Verification Commands
The following test commands verify SlashCommand tool capabilities:

#### `/test:slashcommand-recursion [level] [target]`
Tests recursive slash command invocation via SlashCommand tool.
- Location: `.claude/commands/test/slashcommand-recursion.md`
- Tests self-invocation and cross-invocation patterns
- Includes safety limit at recursion level 3

#### `/test:worker-to-slashcommand [level]`
Tests whether workers can invoke slash commands that create other workers.
- Location: `.claude/commands/test/worker-to-slashcommand.md`
- Creates workers that use SlashCommand tool
- Demonstrates cross-context orchestration

#### `/test:slashcommand-to-worker [level]`
Companion command for worker orchestration testing.
- Location: `.claude/commands/test/slashcommand-to-worker.md`
- Creates workers when invoked by other workers
- Validates Task tool availability in worker-invoked commands

#### `/test:README`
Overview of the test suite with usage instructions.
- Location: `.claude/commands/test/README.md`
- Explains all tests and their purposes
- Documents key findings and safety considerations

### Running the Tests
1. Restart Claude Code (required for new commands)
2. Run: `/test:README` for complete test documentation
3. Run: `/test:worker-to-slashcommand 1` to test worker → slash command → worker chains
4. Run: `/test:slashcommand-recursion 1` to test nested slash command invocations
5. Observe recursion limiting at level 3

## File Locations
| Component | Project | Global |
|-----------|---------|--------|
| Slash commands | `.claude/commands` | `~/.claude/commands` |
| Subagents | `.claude/agents` | `~/.claude/agents` |
| Workers | `workers/` | `~/.claude/workers` |
