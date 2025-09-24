---
description: Test whether workers/subagents can invoke slash commands that create other workers
allowed-tools: Task, SlashCommand
argument-hint: [recursion-level]
---

# Test: Worker → SlashCommand → Worker Chain

## Purpose
Verifies that workers (invoked via Task tool) can use the SlashCommand tool to invoke slash commands, which can then create new workers - demonstrating cross-context orchestration capabilities.

## Test Parameters
- **Recursion Level**: $ARGUMENTS (default: 1)
- **Maximum Depth**: 3 (hardcoded safety limit)

## Test Architecture
```
Slash Command (this)
└─> Task tool → Worker (fresh context)
    └─> SlashCommand tool → Another slash command
        └─> Task tool → Another worker
            └─> (continues until depth 3)
```

## Safety Check
If recursion level >= 3:
- STOP execution
- Report: "Maximum depth reached. Worker-to-SlashCommand chain verified."

## Test Execution (if level < 3)

### Create Test Worker
Use Task tool with this worker prompt:

```
You are a test worker at recursion level $ARGUMENTS in a fresh context.

Your mission:
1. Report: "Worker executing at level $ARGUMENTS (fresh context)"
2. Verify you have access to SlashCommand tool
3. If level < 3, invoke: /test:slashcommand-to-worker NEXT_LEVEL
   (where NEXT_LEVEL = current level + 1)
4. Report success/failure of the SlashCommand invocation

This tests cross-context orchestration: workers in fresh contexts can trigger main-context slash commands.
```

## What This Tests
1. Workers have SlashCommand tool access
2. Fresh-context workers can invoke main-context commands
3. Commands invoked by workers can create new workers
4. Complex orchestration patterns are possible
5. Workers can work around Task tool limitations