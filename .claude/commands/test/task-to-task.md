---
description: Test whether Tasks (workers/subagents) can invoke other Tasks - expects failure
allowed-tools: Task
---

# Test: Task → Task Invocation (Expected Failure)

## Purpose
Verifies that Tasks (workers/subagents) CANNOT use the Task tool to invoke other tasks, confirming the framework limitation that prevents recursive Task delegation.

## Expected Result
❌ **This test should FAIL** - Workers/subagents cannot use the Task tool

## Test Architecture
```
This Slash Command
└─> Task tool → Worker/Subagent
    └─> Attempts Task tool → Another Worker (SHOULD FAIL)
```

## Test Execution

### Step 1: Create Test Worker
Use Task tool to create a worker that will attempt to use Task tool:

```
You are a test worker created to verify Task tool limitations.

Your mission is to TEST THE FRAMEWORK LIMITATION:

1. Report: "Worker active. Testing Task tool access..."

2. Attempt to use the Task tool with this configuration:
   - subagent_type: 'general-purpose'
   - description: 'Nested task attempt'
   - prompt: 'You are a nested worker. Report: "This should not work - nested Task invocation succeeded!"'

3. Report the outcome:
   - If Task tool works: "❌ TEST FAILED - UNEXPECTED: Task tool worked in worker context!"
   - If Task tool fails: "✅ TEST PASSED - EXPECTED: Task tool not available to workers (framework limitation confirmed)"
   - If tool not found: "✅ TEST PASSED - CONFIRMED: Workers do not have access to Task tool"

This test verifies that the framework correctly prevents recursive Task delegation.
```

## What This Tests
1. Confirms workers/subagents DO NOT have Task tool access
2. Validates the "no recursive delegation" framework rule
3. Demonstrates why workers need SlashCommand tool for orchestration
4. Shows the fundamental difference between Task and SlashCommand tools

## Expected Error Messages
Likely outcomes:
- "Tool 'Task' not found" or similar
- "Workers cannot use Task tool"
- Silent failure with error in tool invocation

## Why This Matters
This limitation is WHY the SlashCommand tool is so important:
- Workers cannot create other workers directly
- But they CAN invoke slash commands (which can create workers)
- This enables orchestration through an indirect path