# Framework Simplification List v1.0

## Executive Summary

This document outlines the architectural limitations in Claude Code's agent/command framework and prioritizes the necessary fixes to align with actual Claude Code capabilities. The fundamental constraints are:

1. **Commands cannot execute other slash commands** - They run in the main Claude session but cannot invoke other commands
2. **Subagents cannot invoke other subagents** - They cannot use the Task tool to delegate to other agents
3. **Subagents cannot execute slash commands** - They run in isolated contexts without command access

These limitations require significant refactoring of the current framework, which incorrectly assumes these capabilities exist.

## Critical Architectural Constraints

### Claude Code Execution Model

| Component | Execution Context | Can Access | Cannot Access |
|-----------|------------------|------------|---------------|
| **Main Claude** | Full conversation | Task tool (invoke subagents), all tools | Direct slash command execution |
| **Slash Commands** | Main session with context | Task tool (invoke subagents), all allowed tools, @mentions for context | Other slash commands directly |
| **Subagents** | Isolated context | Their allowed tools only | Task tool (no recursive delegation), other agents, slash commands |

### Valid Patterns
1. **Commands using Task to invoke worker subagents** ✅ (parallel execution is valid)
2. **Main Claude using Task to invoke subagents** ✅
3. **Commands reading other command files for reference** ✅

### Invalid Patterns Currently in Use
1. **Subagents with Task tool attempting to delegate to other subagents** ❌ (no recursive delegation)
2. **References to executing slash commands from subagents** ❌ 
3. **Commands trying to directly execute other slash commands** ❌
4. **Optimizer agents (which are subagents) having Task tool** ❌

## Priority 1: Critical Infrastructure Components (Must Fix First)

These components are foundational and other components depend on them working correctly.

### 1.1 command-optimizer (agents/command-optimizer.md)
**Issue**: Has Task tool access, which violates subagent limitations
**Problem**: 
- Subagents cannot use Task to invoke other subagents
- The optimizer itself is a subagent but has Task tool
- References using @slash-command-executor pattern which won't work from subagent context
**Fix Required**: 
- Remove Task tool from allowed tools (subagents cannot delegate)
- Keep the logic for creating companion worker subagents (this is valid for commands to use)
- Ensure created workers don't have Task tool themselves
- Fix slash-command-executor references to use direct file reading instead
**Dependencies**: Many commands depend on this for optimization
**Note**: Creating worker subagents for commands is VALID - commands can use Task to invoke workers

### 1.2 subagent-optimizer (agents/subagent-optimizer.md)
**Issue**: Has Task tool access, which violates subagent limitations
**Problem**: 
- Subagents cannot use Task to invoke other subagents
- Includes logic for handling slash command references that assumes Task usage
- Can create circular dependencies if optimizing itself
**Fix Required**: 
- Remove Task tool from allowed tools
- Simplify to only optimize YAML frontmatter and descriptions
- Remove logic about delegating to slash-command-executor
**Dependencies**: Many agents depend on this for optimization

### 1.3 Optimization Directive (directives/0000_optimization_of_commands_and_agents.md)
**Issue**: Directs creation of commands/agents that then call optimizer agents
**Problem**: Creates potential circular dependencies and assumes agents can optimize themselves
**Fix Required**: 
- Change to manual optimization workflow
- Or create a main-session only optimization approach
- Remove automatic optimization requirements

## Priority 2: Command Execution Infrastructure

### 2.1 slash-command-executor (agents/slash-command-executor.md)
**Issue**: Architectural mismatch - trying to execute commands from subagent context
**Problem**: 
- Subagents cannot actually execute slash commands
- The entire premise of this agent is flawed
**Fix Required**: 
- Either DELETE this agent entirely
- Or convert to a documentation reader that extracts command instructions
- Cannot actually execute commands as a subagent

## Priority 3: Commands with Task Tool Dependencies

These commands use Task tool to delegate to subagents, which is VALID. The pattern of commands using Task to invoke worker subagents (including parallel execution) is correct and should be preserved. We just need to ensure the worker subagents themselves don't have Task tool.

### 3.1 /subagents:review-ecosystem (commands/subagents/review-ecosystem.md)
**Status**: Pattern is VALID - commands can use Task for parallel workers
**Verification Needed**: Ensure cmd-review-subagent-ecosystem-analyzer has no Task tool
**No Fix Required**: The command's use of Task is correct

### 3.2 /git:commit-and-push (commands/git/commit-and-push.md)
**Status**: Pattern is VALID - commands can use Task for parallel workers
**Verification Needed**: Ensure all cmd-commit-and-push-* agents have no Task tool

### 3.3 /memory:learn (commands/memory/learn.md)
**Status**: Pattern is VALID - commands can use Task
**Verification Needed**: Ensure cmd-learn-analyzer has no Task tool

### 3.4 /docs:capture-session and /docs:capture-strategy
**Status**: Pattern is VALID - commands can use Task
**Verification Needed**: Ensure cmd-capture-session-analyzer has no Task tool

### 3.5 /commands:normalize (commands/commands/normalize.md)
**Status**: Pattern is VALID - commands can use Task
**Verification Needed**: Ensure cmd-commands-normalize-analyzer has no Task tool

### 3.6 /commands:create (commands/commands/create.md)
**Status**: Pattern is VALID for validator invocation
**Issue**: References @command-optimizer which itself needs fixing (Priority 1)
**Fix Required**: 
- Wait for command-optimizer to be fixed (remove its Task tool)
- Ensure cmd-create-command-validator has no Task tool

### 3.7 /jobs:do (commands/jobs/do.md)
**Status**: Pattern is VALID - commands can use Task
**Verification Needed**: Ensure cmd-jobs-do-worker has no Task tool

### 3.8 /jobs:auto-improve (commands/jobs/auto-improve.md)
**Status**: Pattern is VALID - commands can use Task
**Verification Needed**: Ensure cmd-jobs-auto-improve-scanner has no Task tool

## Priority 4: Agents with Invalid Task Tool Access

These agents have Task tool but shouldn't as subagents cannot delegate.

### 4.1 documentation-auditor (agents/documentation-auditor.md)
**Issue**: Has Task tool in allowed tools
**Fix Required**: Remove Task tool, refactor to not delegate

### 4.2 hack-spotter (agents/hack-spotter.md)
**Issue**: Has Task tool in allowed tools
**Fix Required**: Remove Task tool, refactor to not delegate

### 4.3 implan-auditor (agents/implan-auditor.md)
**Issue**: Has Task tool in allowed tools
**Fix Required**: Remove Task tool, refactor to not delegate

### 4.4 implan-generator (agents/implan-generator.md)
**Issue**: Has Task tool in allowed tools
**Fix Required**: Remove Task tool, refactor to not delegate

### 4.5 memory-keeper (agents/memory-keeper.md)
**Issue**: Has Task tool in allowed tools
**Fix Required**: Remove Task tool, refactor to not delegate

## Priority 5: Worker/Analyzer Agents

These cmd-* agents are invoked by commands and must not have Task tool or try to delegate.

### 5.1 cmd-* analyzer/worker agents
All of these should be verified to have no Task tool and no delegation attempts:
- cmd-commit-and-push-analyzer.md
- cmd-commit-and-push-security.md
- cmd-commit-and-push-validator.md
- cmd-commands-normalize-analyzer.md
- cmd-capture-session-analyzer.md
- cmd-create-command-validator.md
- cmd-learn-analyzer.md
- cmd-review-subagent-ecosystem-analyzer.md
- cmd-jobs-auto-improve-scanner.md
- cmd-jobs-do-worker.md

## Priority 6: Commands Needing Simplification

### 6.1 /implan:execute and /implan:create
**Issue**: Complex workflows that may assume delegation capabilities
**Fix Required**: Simplify to direct execution without complex agent orchestration

### 6.2 /docs:readme-audit
**Issue**: May reference other commands or complex workflows
**Fix Required**: Simplify to direct execution

## Implementation Order

1. **Phase 1: Fix Infrastructure (Priority 1)**
   - Fix optimizer agents first (remove Task tool)
   - Update optimization directive
   - These affect everything else

2. **Phase 2: Fix Execution Model (Priority 2)**
   - Delete or refactor slash-command-executor
   - Remove invalid execution patterns

3. **Phase 3: Fix Agent Task Access (Priority 4)**
   - Remove Task tool from all subagents
   - Subagents should never delegate

4. **Phase 4: Verify Worker Agents (Priority 5)**
   - Ensure no cmd-* agents have Task tool
   - Verify they don't attempt delegation

5. **Phase 5: Fix Commands (Priority 3 & 6)**
   - Update commands to work with fixed agents
   - Simplify complex orchestration patterns

## Recommended Architecture (Based on Actual Constraints)

### The Valid Pattern: Command-Worker Architecture
- **Commands CAN use Task** to invoke multiple worker subagents in parallel ✅
- **Worker subagents CANNOT have Task** - they do their work and return results ✅
- **Main Claude CAN use Task** to invoke any subagent ✅
- **Parallel execution IS VALID** when commands invoke workers ✅

This is actually what most of the framework already does correctly! The main issues are:
1. Some subagents incorrectly have Task tool (optimizers, auditors, etc.)
2. The slash-command-executor concept is fundamentally flawed
3. Some references to executing slash commands from wrong contexts

### What Works and Should Be Preserved
- The cmd-* worker pattern for parallel execution
- Commands using Task to orchestrate work
- The separation between orchestration (commands) and execution (workers)

## Testing Strategy

After each phase:
1. Test the modified component in isolation
2. Test components that depend on it
3. Verify no circular dependencies exist
4. Ensure error messages are clear when limitations are hit

## Success Criteria

- No subagent has Task tool access
- No component attempts to execute slash commands except in main session
- All optimization is either manual or happens in main session
- Clear error messages when users attempt invalid operations
- Framework works within Claude Code's actual constraints