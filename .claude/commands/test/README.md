---
description: Overview of SlashCommand tool test suite
allowed-tools: Read
---

# Test Suite Overview: SlashCommand Tool Capabilities

## Available Tests

### `/test:test-all` - RUN ALL TESTS
**Purpose**: Meta test that runs ALL test commands and checks for deviations
**What it does**:
- Dynamically discovers all test:*.md commands
- Executes each test via SlashCommand tool
- Verifies expected behaviors
- Reports any deviations from expected outcomes

**Usage**:
```bash
/test:test-all  # Run complete test suite
```

**Output**: Comprehensive report showing pass/fail/deviation for each test

---

### Individual Tests

### 1. `/test:task-to-task`
**Purpose**: Tests that Tasks CANNOT invoke other Tasks (expected failure)
**What it does**:
- Creates a worker via Task tool
- Worker attempts to use Task tool (should fail)
- Confirms framework limitation: "no recursive Task delegation"
- Demonstrates why SlashCommand tool is essential for orchestration

**Usage**:
```bash
/test:task-to-task  # Verify Task tool limitation
```

**Expected Result**: ❌ FAILURE (by design) - confirms workers cannot use Task tool

### 2. `/test:slashcommand-recursion [level] [target]`
**Purpose**: Tests recursive slash command invocation
**What it does**:
- Slash commands invoking themselves or other slash commands
- Demonstrates SlashCommand tool availability in slash commands
- Includes safety limit at recursion level 3

**Usage**:
```bash
/test:slashcommand-recursion 1  # Self-invocation test
/test:slashcommand-recursion 1 another-command  # Cross-invocation
```

### 2. `/test:worker-to-slashcommand [level]`
**Purpose**: Tests worker → slash command → worker chains
**What it does**:
- Creates a worker via Task tool
- Worker uses SlashCommand tool to invoke a slash command
- That command creates another worker
- Demonstrates cross-context orchestration

**Usage**:
```bash
/test:worker-to-slashcommand 1  # Start the chain
```

### 3. `/test:slashcommand-to-worker [level]`
**Purpose**: Companion to worker-to-slashcommand test
**What it does**:
- Slash command that creates workers
- Designed to be invoked by workers
- Continues the orchestration chain

**Note**: This is typically invoked by the worker-to-slashcommand test, not directly.

### 4. `/test:agent-to-agent`
**Purpose**: Tests that agents CANNOT invoke other agents (expected failure)
**What it does**:
- Creates an agent via Task tool
- Agent attempts to invoke another agent (should fail)
- Confirms agents don't have Task tool access

**Expected Result**: ❌ FAILURE (by design) - confirms agents cannot invoke agents

### 5. `/test:agent-to-task`
**Purpose**: Tests that agents CANNOT use Task tool (expected failure)
**What it does**:
- Creates an agent that attempts to use Task tool
- Confirms Task tool is filtered from agent context
- Validates framework limitation

**Expected Result**: ❌ FAILURE (by design) - confirms agents lack Task tool

### 6. `/test:task-to-agent`
**Purpose**: Tests that workers CANNOT invoke agents (expected failure)
**What it does**:
- Creates a worker that attempts to invoke an agent
- Confirms workers cannot invoke agents (no Task tool)
- Validates execution hierarchy

**Expected Result**: ❌ FAILURE (by design) - confirms workers cannot invoke agents

## Key Findings Demonstrated

### Universal SlashCommand Tool Access
✅ **Main Claude** has SlashCommand tool
✅ **Slash Commands** have SlashCommand tool
✅ **Subagents** have SlashCommand tool
✅ **Workers** have SlashCommand tool

### Orchestration Capabilities
- Workers can invoke slash commands that create workers
- Slash commands can recursively invoke themselves
- Fresh-context workers can trigger main-context operations
- Complex delegation chains are possible

### Safety Considerations
⚠️ **No built-in circular dependency protection**
All tests include manual recursion limits (depth 3) to prevent infinite loops.

## Running the Tests

1. **Restart Claude Code** after creating/modifying test commands
2. Run individual tests with their commands
3. Observe recursion limiting at level 3
4. Check output for verification of capabilities

## Test Results Summary

All tests confirm:
1. SlashCommand tool is universally available
2. Complex orchestration patterns work as expected
3. Manual safety mechanisms are effective
4. No framework-level restrictions on these patterns