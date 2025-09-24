---
description: Test recursive slash command invocation via SlashCommand tool with safety limits
allowed-tools: SlashCommand
disable-model-invocation: true
argument-hint: [recursion-level] [target-command]
---

# Test: SlashCommand Tool Recursion

## Purpose
Verifies that slash commands can recursively invoke themselves or other slash commands using the SlashCommand tool, with built-in safety limits to prevent infinite loops.

## Test Parameters
- **Recursion Level**: $1 (default: 1)
- **Target Command**: $2 (default: self-invocation)

## Safety Check
```
Current recursion level: $1
Maximum allowed: 3
```

If recursion level >= 3:
- STOP execution
- Report: "Maximum recursion depth reached. Test completed successfully."

## Test Execution

### Step 1: Report Current State
"SlashCommand recursion test at level $1"

### Step 2: Recursive Invocation (if level < 3)
Increment level and invoke:
- If $2 provided: `/test:$2 NEXT_LEVEL`
- Otherwise: `/test:slashcommand-recursion NEXT_LEVEL`

Where NEXT_LEVEL = current level + 1

## Expected Behavior
- Level 1: Executes and invokes level 2
- Level 2: Executes and invokes level 3
- Level 3: Stops execution (safety limit)

## What This Tests
- SlashCommand tool availability in slash commands
- Recursive invocation capability
- Safety mechanism effectiveness
- No framework-level restrictions on self-invocation