---
description: Test slash command creating workers (part of worker-to-slashcommand chain)
allowed-tools: Task, SlashCommand
disable-model-invocation: true
argument-hint: [recursion-level]
---

# Test: SlashCommand → Worker Creation

## Purpose
Companion command for worker-to-slashcommand test. Demonstrates that slash commands invoked by workers can successfully create new workers via Task tool.

## Test Parameters
- **Recursion Level**: $ARGUMENTS (default: 1)
- **Maximum Depth**: 3

## Current State
"Slash command invoked by worker, now at level $ARGUMENTS"

## Safety Check
If level >= 3:
- Report: "Maximum depth (3) reached. Chain complete."
- STOP

## Test Execution (if level < 3)

### Create New Worker
Use Task tool to create a worker:

```
You are a worker created by a slash command at level $ARGUMENTS.

This slash command was invoked by a previous worker, demonstrating:
- Workers CAN invoke slash commands
- Those commands CAN create new workers
- This enables complex orchestration despite Task tool limitations

Your tasks:
1. Confirm: "Worker created at level $ARGUMENTS via slash command"
2. If level < 3, continue chain: /test:worker-to-slashcommand NEXT_LEVEL
   (NEXT_LEVEL = current + 1)
3. Report outcome

This proves workers can orchestrate complex operations through slash commands.
```

## Chain Visualization
```
Worker (level N-1)
└─> SlashCommand tool → This command
    └─> Task tool → New Worker (level N)
        └─> SlashCommand tool → Next command...
```

## What This Validates
- Slash commands maintain Task tool access when invoked by workers
- The execution chain can alternate between contexts
- No framework restrictions on this pattern