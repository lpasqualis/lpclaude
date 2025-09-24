---
description: Test whether Tasks (workers) can invoke agents - expects failure
allowed-tools: Task
---

# Test: Task → Agent Invocation (Expected Failure)

## Purpose
Verifies that Tasks (workers created via Task tool) CANNOT invoke agents (subagents), since workers don't have access to the Task tool required for agent invocation.

## Expected Result
❌ **This test should FAIL** - Workers cannot invoke agents (no Task tool access)

## Test Architecture
```
This Slash Command
└─> Task tool → Worker (general-purpose)
    └─> Attempts to invoke test-agent-primary (SHOULD FAIL)
```

## Required Test Agent
This test uses the test agent in `.claude/agents/`:
- **test-agent-primary**: The agent that the worker attempts to invoke

## Test Execution

### Create Test Worker
Use Task tool to create a worker that will attempt to invoke an agent:

```
You are a test worker created to verify agent invocation limitations.

Your mission is to TEST THE FRAMEWORK LIMITATION:

1. Report: "Worker active. Testing ability to invoke an agent..."

2. Attempt to invoke test-agent-primary. Try using Task tool with:
   - subagent_type: 'test-agent-primary'
   - description: 'Agent invocation from worker'
   - prompt: 'If you are running, report: TEST FAILED - worker successfully invoked an agent!'

3. Report the outcome:
   - If agent invocation works: "❌ TEST FAILED - UNEXPECTED: Worker could invoke an agent!"
   - If Task tool not available: "✅ TEST PASSED - CONFIRMED: Workers cannot invoke agents (no Task tool)"
   - If no agent invocation method exists: "✅ TEST PASSED - EXPECTED: Workers lack mechanism to invoke agents"

This test verifies that workers cannot invoke agents, maintaining the execution hierarchy.
```

## What This Tests
1. Confirms workers CANNOT invoke agents
2. Validates workers don't have Task tool access
3. Ensures proper execution hierarchy (only Main Claude and Slash Commands can invoke agents)
4. Demonstrates limitation that requires SlashCommand tool for orchestration

## Expected Outcome
Worker should report:
- "✅ TEST PASSED - CONFIRMED: Workers cannot invoke agents (no Task tool)"
- Task tool not found in available functions

## Why This Matters
This limitation ensures:
- Workers cannot create complex delegation chains
- Agent invocation remains controlled at higher levels
- Clear separation between worker and agent capabilities
- Workers must use SlashCommand tool to trigger agent invocation indirectly