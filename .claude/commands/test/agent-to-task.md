---
description: Test whether agents (subagents) can use Task tool - expects failure
allowed-tools: Task
---

# Test: Agent → Task Tool Usage (Expected Failure)

## Purpose
Verifies that agents (subagents) CANNOT use the Task tool to create workers or invoke other tasks, confirming the "no Task tool for agents" framework rule.

## Expected Result
❌ **This test should FAIL** - Agents cannot use Task tool

## Test Architecture
```
This Slash Command
└─> Task tool → test-agent-primary
    └─> Attempts to use Task tool (SHOULD FAIL)
```

## Required Test Agent
This test requires the test agent in `.claude/agents/`:
- **test-agent-primary**: The agent that attempts to use Task tool

## Test Execution

### Invoke Test Agent
Use Task tool to invoke test-agent-primary with Task tool test instructions:

```
subagent_type: 'test-agent-primary'
description: 'Test agent Task tool access'
prompt: 'Test Task tool usage. Try to use Task tool to create a worker with subagent_type: general-purpose.'
```

The test-agent-primary will:
1. Report its status
2. List available tools
3. Attempt to use Task tool to create a worker
4. Report whether Task tool is available or not

## What This Tests
1. Confirms agents DO NOT have Task tool in their function set
2. Validates the framework filtering of Task tool from agent contexts
3. Ensures agents cannot bypass hierarchy through Task tool
4. Demonstrates why agents need SlashCommand tool for orchestration

## Expected Outcome
test-agent-primary should report:
- "✅ TEST PASSED - Agents cannot use Task tool"
- List of available tools (should NOT include Task)

## Why This Matters
This limitation:
- Prevents recursive task delegation
- Maintains clear execution boundaries
- Forces agents to use SlashCommand tool for complex orchestration
- Ensures predictable resource usage (no unlimited task spawning)