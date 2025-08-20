# Framework Simplification List v1.1

## Executive Summary

**REVISED UNDERSTANDING**: After clarification, the architectural constraints are more nuanced than initially assessed. The key insight is that **commands CAN use Task to invoke worker subagents** (including parallel execution), which is a valid and powerful pattern. The main issues are:

1. **Subagents cannot invoke other subagents** - No recursive Task tool usage
2. **Subagents cannot execute slash commands** - They run in isolated contexts
3. **Commands cannot directly execute other slash commands** - But they CAN use Task to invoke workers

Most of the framework's parallelization patterns are actually VALID and should be preserved.

## Correct Architectural Model

### Claude Code Execution Hierarchy

```
Main Claude Session
    ├── Can use Task → Invoke any subagent
    ├── Can execute → Slash commands
    └── Slash Commands (run in main session)
            ├── Can use Task → Invoke worker subagents (parallel OK!)
            ├── Cannot → Execute other slash commands directly
            └── Worker Subagents (isolated context)
                    ├── Can use → Their allowed tools
                    ├── Cannot use → Task tool (no recursive delegation)
                    └── Cannot → Execute slash commands
```

### Valid Patterns ✅
1. **Commands using Task to invoke multiple worker subagents in parallel**
2. **Main Claude using Task to invoke any subagent**
3. **Commands creating cmd-* worker agents for parallel execution**
4. **Commands reading other command files for reference**

### Invalid Patterns ❌
1. **Subagents with Task tool attempting recursive delegation**
2. **Subagents trying to execute slash commands**
3. **Commands trying to directly execute other slash commands**
4. **The slash-command-executor agent concept** (subagents can't execute commands)

## Revised Priority List

## Priority 1: Fix Subagents with Invalid Task Tool

These subagents have Task tool but cannot use it (no recursive delegation allowed).

### 1.1 command-optimizer (agents/command-optimizer.md)
**Current State**: Has Task tool (invalid for subagent)
**What's Good**: Logic for creating companion worker subagents is VALID
**Fix Required**: 
- Remove Task tool from allowed tools
- KEEP the parallelization logic (it's correct for commands to use!)
- Fix slash-command references to use direct file reading
- Ensure created workers don't have Task tool

### 1.2 subagent-optimizer (agents/subagent-optimizer.md)
**Current State**: Has Task tool (invalid for subagent)
**Fix Required**: 
- Remove Task tool from allowed tools
- Update logic about slash command handling (no delegation possible)

### 1.3 Other agents with invalid Task tool
Remove Task tool from:
- documentation-auditor
- hack-spotter
- implan-auditor
- implan-generator
- memory-keeper

## Priority 2: Fix Conceptually Flawed Components

### 2.1 slash-command-executor (agents/slash-command-executor.md)
**Fundamental Issue**: Subagents cannot execute slash commands
**Options**:
1. DELETE entirely (recommended)
2. Convert to command-documentation-reader that only extracts instructions
3. Move functionality to main session somehow

### 2.2 Optimization Directive (directives/0000_optimization_of_commands_and_agents.md)
**Issue**: Assumes subagents can invoke optimizers
**Fix**: Update to clarify optimization happens from main session only

## Priority 3: Verify Worker Agents

These cmd-* agents are correctly invoked by commands via Task. Just ensure they don't have Task tool themselves.

### All cmd-* agents (NO CHANGES if they don't have Task)
- cmd-commit-and-push-analyzer ✓
- cmd-commit-and-push-security ✓
- cmd-commit-and-push-validator ✓
- cmd-commands-normalize-analyzer ✓
- cmd-capture-session-analyzer ✓
- cmd-create-command-validator ✓
- cmd-learn-analyzer ✓
- cmd-review-subagent-ecosystem-analyzer ✓
- cmd-jobs-auto-improve-scanner ✓
- cmd-jobs-do-worker ✓

## Priority 4: Commands Need Minor Updates

Most commands are actually CORRECT! They properly use Task to invoke workers.

### Commands that are ALREADY CORRECT:
- /git:commit-and-push - ✅ Correctly uses Task for parallel workers
- /memory:learn - ✅ Correctly uses Task
- /docs:capture-session - ✅ Correctly uses Task
- /docs:capture-strategy - ✅ Correctly uses Task
- /commands:normalize - ✅ Correctly uses Task
- /jobs:do - ✅ Correctly uses Task
- /jobs:auto-improve - ✅ Correctly uses Task
- /subagents:review-ecosystem - ✅ Correctly uses Task

### Commands needing minor fixes:
- /commands:create - Wait for command-optimizer fix (Priority 1.1)

## Implementation Plan (Simplified)

### Phase 1: Remove Task from Subagents (Priority 1)
- Quick fix: Remove Task tool from 7 subagents
- Preserve their core logic, especially parallelization patterns in optimizers

### Phase 2: Handle Flawed Components (Priority 2)
- Delete or redesign slash-command-executor
- Update optimization directive

### Phase 3: Verify Workers (Priority 3)
- Quick check: Ensure no cmd-* agents have Task tool
- Most are probably already correct

### Phase 4: Minor Command Updates (Priority 4)
- Most commands are already correct!
- Fix any remaining references to flawed patterns

## Key Insights

1. **The framework is more correct than initially thought** - Most parallelization patterns are valid
2. **The main issue is subagents with Task tool** - Easy to fix by removing the tool
3. **Command-worker pattern is powerful and valid** - Should be preserved and encouraged
4. **Parallel execution from commands works great** - This is a strength of the framework

## Success Metrics

- ✅ No subagent has Task tool
- ✅ Commands continue to use Task for parallel workers (this is good!)
- ✅ Clear understanding of what can delegate to what
- ✅ slash-command-executor is removed or completely redesigned
- ✅ Framework leverages valid parallelization patterns effectively

## What NOT to Change

- **Don't remove Task from commands** - They need it for worker invocation
- **Don't remove parallelization logic** - It's valid and valuable
- **Don't simplify cmd-* worker patterns** - They work correctly
- **Don't change the basic command-worker architecture** - It's sound