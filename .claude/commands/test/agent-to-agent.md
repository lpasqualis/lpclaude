---
description: Test whether agents (subagents) can invoke other agents - expects failure
allowed-tools: Task
disable-model-invocation: true
---

# Test: Agent → Agent Invocation (Expected Failure)

## Purpose
Verifies that agents (subagents) CANNOT invoke other agents, confirming that agents lack the Task tool needed for agent invocation.

## Expected Result
❌ **This test should FAIL** - Agents cannot invoke other agents (no Task tool access)

## Test Architecture
```
This Slash Command
└─> Task tool → test-agent-primary
    └─> Attempts to invoke test-agent-secondary (SHOULD FAIL)
```

## Required Test Agents
This test requires two test agents in `.claude/agents/`:
- **test-agent-primary**: The agent that attempts invocation
- **test-agent-secondary**: Should never actually be invoked

## Test Execution

### Invoke Primary Test Agent
Use Task tool to invoke test-agent-primary:

```
subagent_type: 'test-agent-primary'
description: 'Test agent-to-agent invocation'
prompt: 'Test agent-to-agent invocation. Try to invoke test-agent-secondary using Task tool.'
```

The test-agent-primary will:
1. Check its available tools
2. Attempt to invoke test-agent-secondary
3. Report pass/fail based on whether Task tool is available

## What This Tests
1. Confirms agents DO NOT have Task tool access
2. Validates agents cannot invoke other agents
3. Ensures execution hierarchy is maintained
4. Demonstrates fundamental limitation of agent capabilities

## Expected Outcome
test-agent-primary should report:
- "✅ TEST PASSED - Agents cannot invoke other agents (no Task tool)"

If test-agent-secondary runs, it will report:
- "❌ TEST FAILED - CRITICAL: Agent successfully invoked another agent!"

## Why This Matters
This limitation ensures:
- Clear execution hierarchy
- No recursive agent delegation
- Predictable agent behavior
- Agents must use SlashCommand tool for orchestration instead